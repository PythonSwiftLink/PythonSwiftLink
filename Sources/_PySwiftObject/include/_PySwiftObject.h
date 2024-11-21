//
//  _PySwiftObject.h
//  
//
//  Created by CodeBuilder on 21/01/2024.
//

#ifndef _PySwiftObject_h
#define _PySwiftObject_h

#include "Python.h"

typedef struct {
	PyObject_HEAD
	PyObject* dict;
	void* swift_ptr;
	
	//int object_info; // considering this
	
} PySwiftObject;

PyModuleDef_Base _PyModuleDef_HEAD_INIT;

//long PySwiftObject_dict_offset;
long PySwiftObject_size;

PyObject* PySwiftObject_New(PyTypeObject *type);
PySwiftObject* PySwiftObject_Cast(PyObject* o);

#endif /* _PySwiftObject_h */
