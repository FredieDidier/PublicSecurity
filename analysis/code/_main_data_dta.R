# Function to shorten variable names
encurtar_nome <- function(nome, sufixo = "") {
  # Limit the name to 32 characters (Stata) already counting the suffix
  limite <- 32 - nchar(sufixo)
  nome <- substr(nome, 1, limite)
  # Concatenate the suffix, if any
  nome <- paste0(nome, sufixo)
  return(nome)
}

# Function to transform names into valid ones for Stata
ajustar_nomes_stata <- function(nome, sufixo = "") {
  # Replace non-allowed characters with underscores
  nome <- str_replace_all(nome, "[^a-zA-Z0-9_]", "_")
  
  # Ensure the name starts with a letter (Stata requires this)
  if (!grepl("^[a-zA-Z]", nome)) {
    nome <- paste0("v_", nome)  # Prefix 'v_' if the name starts with a number or symbol
  }
  
  # Shorten the name to 32 characters including the suffix
  nome <- encurtar_nome(nome, sufixo)
  
  return(nome)
}

# Function to ensure names are unique
garantir_nomes_unicos <- function(nomes) {
  # Create vector to store the new unique names
  nomes_unicos <- character(length(nomes))
  
  # Counter to add numeric suffixes
  contador <- integer(length(nomes))
  
  for (i in seq_along(nomes)) {
    nome_atual <- nomes[i]
    sufixo <- ""
    
    # Ensure the name is unique
    while (nome_atual %in% nomes_unicos) {
      contador[i] <- contador[i] + 1
      sufixo <- paste0("_", contador[i])
      nome_atual <- ajustar_nomes_stata(nomes[i], sufixo)
    }
    
    # Assign the adjusted unique name to the names vector
    nomes_unicos[i] <- nome_atual
  }
  
  return(nomes_unicos)
}

# Function to identify and adjust problematic column names
ajustar_colunas <- function(df) {
  # Generate new names by applying the ajustar_nomes_stata function to each column name
  novos_nomes <- names(df) %>%
    sapply(ajustar_nomes_stata, USE.NAMES = FALSE)
  
  # Ensure names are unique, adding numeric suffixes if necessary
  novos_nomes <- garantir_nomes_unicos(novos_nomes)
  
  # Check which names were modified
  colunas_modificadas <- names(df) != novos_nomes
  
  # Display columns that were renamed
  if (any(colunas_modificadas)) {
    cat("Renamed columns:\n")
    print(data.frame(Old = names(df)[colunas_modificadas], New = novos_nomes[colunas_modificadas]))
  }
  
  # Replace old names with new ones in the dataframe
  names(df) <- novos_nomes
  
  return(df)
}

# Example usage with your dataframe called "data"
main_data_stata <- ajustar_colunas(main_data)

# Now you can save the dataframe in .dta format (Stata)
write_dta(main_data_stata, paste0(DROPBOX_PATH, "build/workfile/output/main_data.dta"))