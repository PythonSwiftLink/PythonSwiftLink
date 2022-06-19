//
//  FolderMonitor.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 01/06/2022.
//

import Foundation

class FolderMonitor {
    // MARK: Properties
    
    /// A file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt = -1
/// A dispatch queue used for sending file changes in the directory.
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
/// A dispatch source to monitor a file descriptor created from the directory.
    private var folderMonitorSource: DispatchSourceFileSystemObject?
/// URL for the directory being monitored.
    let url: Foundation.URL
    
    var folderDidChange: (() -> Void)?
// MARK: Initializers
init(url: Foundation.URL) {
        self.url = url
    }
// MARK: Monitoring
/// Listen for changes to the directory (if we are not already).
    func startMonitoring() {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else {
            return
            
        }
            // Open the directory referenced by URL for monitoring only.
            monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
// Define a dispatch source monitoring the directory for additions, deletions, and renamings.
            folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor, eventMask: .write, queue: folderMonitorQueue)
// Define the block to call when a file change is detected.
            folderMonitorSource?.setEventHandler { [weak self] in
                self?.folderDidChange?()
            }
        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
            folderMonitorSource?.setCancelHandler { [weak self] in
                guard let strongSelf = self else { return }
                close(strongSelf.monitoredFolderFileDescriptor)
                strongSelf.monitoredFolderFileDescriptor = -1
                strongSelf.folderMonitorSource = nil
            }
        // Start monitoring the directory via the source.
            folderMonitorSource?.resume()
    }
/// Stop listening for changes to the directory, if the source has been created.
    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }
}


class DirectoryMonitor {

    typealias Delegate = DirectoryMonitorDelegate

    init(directory: URL, matching typeIdentifier: String, requestedResourceKeys: Set<URLResourceKey>) {
        self.directory = directory
        self.typeIdentifier = typeIdentifier
        self.requestedResourceKeys = requestedResourceKeys
        self.actualResourceKeys = [URLResourceKey](requestedResourceKeys.union([.typeIdentifierKey]))
        self.contents = []
    }

    let typeIdentifier: String
    let requestedResourceKeys: Set<URLResourceKey>
    private let actualResourceKeys: [URLResourceKey]
    let directory: URL

    weak var delegate: Delegate? = nil

    private(set) var contents: Set<URL>

    fileprivate enum State {
        case stopped
        case started(dirSource: DispatchSourceFileSystemObject)
        case debounce(dirSource: DispatchSourceFileSystemObject, timer: Timer)
    }

    private var state: State = .stopped

    private static func source(for directory: URL) throws -> DispatchSourceFileSystemObject {
        let dirFD = open(directory.path, O_EVTONLY)
        guard dirFD >= 0 else {
            let err = errno
            throw NSError(domain: POSIXError.errorDomain, code: Int(err), userInfo: nil)
        }
        return DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: dirFD,
            eventMask: [.write],
            queue: DispatchQueue.main
        )
    }

    func start() throws {
        guard case .stopped = self.state else { fatalError() }

        let dirSource = try DirectoryMonitor.source(for: self.directory)
        dirSource.setEventHandler {
            self.kqueueDidFire()
        }
        dirSource.resume()
        // We don't support `stop()` so there's no cancellation handler.
        // kqueue.source.setCancelHandler {
        //     _ = close(...)
        // }
        let nowTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
            self.debounceTimerDidFire()
        }
        self.state = .debounce(dirSource: dirSource, timer: nowTimer)
    }

    private func kqueueDidFire() {
        switch self.state {
            case .started(let dirSource):
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                    self.debounceTimerDidFire()
                }
                self.state = .debounce(dirSource: dirSource, timer: timer)
            case .debounce(_, let timer):
                timer.fireDate = Date(timeIntervalSinceNow: 0.2)
                // Stay in the `.debounce` state.
            case .stopped:
                // This can happen if the read source fired and enqueued a block on the
                // main queue but, before the main queue got to service that block, someone
                // called `stop()`.  The correct response is to just do nothing.
                break
        }
    }

    static func contents(of directory: URL, matching typeIdentifier: String, including: [URLResourceKey]) -> Set<URL> {
        guard let rawContents = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: including,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        let filteredContents = rawContents.filter { url in
            guard let v = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
                  let urlType = v.typeIdentifier else {
                return false
            }
            return urlType == typeIdentifier
        }
        return Set(filteredContents)
    }

    private func debounceTimerDidFire() {
        guard case .debounce(let dirSource, let timer) = self.state else { fatalError() }
        timer.invalidate()
        self.state = .started(dirSource: dirSource)

        let newContents = DirectoryMonitor.contents(of: self.directory, matching: self.typeIdentifier, including: self.actualResourceKeys)
        let itemsAdded = newContents.subtracting(self.contents)
        let itemsRemoved = self.contents.subtracting(newContents)
        self.contents = newContents

        if !itemsAdded.isEmpty || !itemsRemoved.isEmpty {
            self.delegate?.didChange(directoryMonitor: self, added: itemsAdded, removed: itemsRemoved)
        }
    }

    func stop() {
        if !self.state.isRunning { fatalError() }
        // I don't need an implementation for this in the current project so
        // I'm just leaving it out for the moment.
        fatalError()
    }
}

fileprivate extension DirectoryMonitor.State {
    var isRunning: Bool {
        switch self {
            case .stopped:  return false
            case .started:  return true
            case .debounce: return true
        }
    }
}

protocol DirectoryMonitorDelegate : AnyObject {
    func didChange(directoryMonitor: DirectoryMonitor, added: Set<URL>, removed: Set<URL>)
}
