set(_output_path
  "${CMAKE_CURRENT_BINARY_DIR}/rosidl_typesupport_c/${PROJECT_NAME}")
set(_generated_sources "")
foreach(_abs_idl_file ${rosidl_generate_interfaces_ABS_IDL_FILES})
  get_filename_component(_parent_folder "${_abs_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)
  get_filename_component(_idl_name "${_abs_idl_file}" NAME_WE)
  string_camel_case_to_lower_case_underscore("${_idl_name}" _header_name)
  list(APPEND _generated_sources
    "${_output_path}/${_parent_folder}/${_header_name}__type_support.cpp"
  )
endforeach()

set(_dependency_files "")
set(_dependencies "")
foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
  foreach(_idl_file ${${_pkg_name}_IDL_FILES})
    set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
    normalize_path(_abs_idl_file "${_abs_idl_file}")
    list(APPEND _dependency_files "${_abs_idl_file}")
    list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
  endforeach()
endforeach()

set(target_dependencies
  ${rosidl_typesupport_c_GENERATOR_FILES}
  "${rosidl_typesupport_c_TEMPLATE_DIR}/action__type_support.c.em"
  "${rosidl_typesupport_c_TEMPLATE_DIR}/idl__type_support.cpp.em"
  "${rosidl_typesupport_c_TEMPLATE_DIR}/msg__type_support.cpp.em"
  "${rosidl_typesupport_c_TEMPLATE_DIR}/srv__type_support.cpp.em"
  ${rosidl_generate_interfaces_ABS_IDL_FILES}
  ${_dependency_files})
foreach(dep ${target_dependencies})
  if(NOT EXISTS "${dep}")
    message(FATAL_ERROR "Target dependency '${dep}' does not exist")
  endif()
endforeach()

get_used_typesupports(typesupports "rosidl_typesupport_c")

set(additional_context_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_typesupport_c__additional_context.json")
write_additional_context(
  "${additional_context_file}"
  TYPE_SUPPORTS ${typesupports}
)

set(generator_arguments_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_typesupport_c__arguments.json")
rosidl_write_generator_arguments(
  "${generator_arguments_file}"
  PACKAGE_NAME "${PROJECT_NAME}"
  IDL_TUPLES "${rosidl_generate_interfaces_IDL_TUPLES}"
  ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
  OUTPUT_DIR "${_output_path}"
  TEMPLATE_DIR "${rosidl_typesupport_c_TEMPLATE_DIR}"
  GENERATOR_FILES "${rosidl_typesupport_c_GENERATOR_FILES}"
  ADDITIONAL_CONTEXT_FILE ${additional_context_file}
  TARGET_DEPENDENCIES ${target_dependencies}
)

list(APPEND rosidl_generator_arguments_files ${generator_arguments_file})
