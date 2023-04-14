function(write_additional_context output_file)
  set(REQUIRED_MULTI_VALUE_KEYWORDS  # only require one of them
    "TYPE_SUPPORTS")

  cmake_parse_arguments(
    ARG
    ""
    ""
    "${REQUIRED_MULTI_VALUE_KEYWORDS}"
    ${ARGN})
  if(ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "write_additional_context() called with unused "
      "arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  set(has_a_required_multi_value_argument FALSE)
  foreach(required_argument ${REQUIRED_MULTI_VALUE_KEYWORDS})
    if(ARG_${required_argument})
      set(has_a_required_multi_value_argument TRUE)
    endif()
  endforeach()
  if(NOT has_a_required_multi_value_argument)
    message(FATAL_ERROR
      "write_additional_context() must be invoked with at least one of "
      "the ${REQUIRED_MULTI_VALUE_KEYWORDS} arguments")
  endif()

  # create folder
  get_filename_component(output_path "${output_file}" PATH)
  file(MAKE_DIRECTORY "${output_path}")

  # open object
  file(WRITE "${output_file}"
    "{")

  set(first_element TRUE)

  # write array values
  foreach(multi_value_argument ${REQUIRED_MULTI_VALUE_KEYWORDS})
    if(ARG_${multi_value_argument})
      # write conditional comma and mandatory newline and indentation
      if(NOT first_element)
        file(APPEND "${output_file}" ",")
      else()
        set(first_element FALSE)
      endif()
      file(APPEND "${output_file}" "\n")

      # write key, open array
      string(TOLOWER "${multi_value_argument}" key)
      file(APPEND "${output_file}"
        "  \"${key}\": [\n")

      # write array values, last without trailing colon
      list(GET ARG_${multi_value_argument} -1 last_value)
      list(REMOVE_AT ARG_${multi_value_argument} -1)
      foreach(value ${ARG_${multi_value_argument}})
        string(REPLACE "\\" "\\\\" value "${value}")
        file(APPEND "${output_file}"
          "    \"${value}\",\n")
      endforeach()
      string(REPLACE "\\" "\\\\" last_value "${last_value}")
      file(APPEND "${output_file}"
        "    \"${last_value}\"\n")

      # close array
      file(APPEND "${output_file}"
        "  ]")
    endif()
  endforeach()

  # close object
  file(APPEND "${output_file}"
    "\n}\n")
endfunction()
