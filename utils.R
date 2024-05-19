###
# Utility functions for censoring stuff
###

# Function for including code files with a `here`-based path.
include_code_file <- function(path, language) {
	glue::glue("
     ```{.%language% include=%path%}
     ```", 
						 .open = "%", .close = "%")
}

# END OF FILE ####
