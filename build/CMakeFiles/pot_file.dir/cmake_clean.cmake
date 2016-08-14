FILE(REMOVE_RECURSE
  "CMakeFiles/pot_file"
  "po/nutty.pot"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/pot_file.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
