
#' Post-translational modifications (PTMs) graph
#'
#' transforms the ptms interactions data.frame to igraph object
#'
#' @return An igraph object
#' @export
#' @import igraph
#' @importFrom dplyr %>% select group_by summarise ungroup
#' @importFrom rlang .data
#' @param ptms data.frame created by \code{\link{import_Omnipath_PTMS}}
#' @examples
#' ptms = import_Omnipath_PTMS(filter_databases=c("PhosphoSite", "Signor"))
#' ptms_g = ptms_graph(ptms = ptms )
#' @seealso  \code{\link{import_Omnipath_PTMS}}
ptms_graph = function(ptms){
    # This is a gene_name based conversion to igraph, i.e. the vertices are 
    # identified by genenames, and not by uniprot IDs.
    # This might cause issue when a gene name encodes multiple uniprot IDs.

    # keep only edge attributes
    edges <- ptms %>% dplyr::select(- c(.data$enzyme, .data$substrate))

    # build vertices: gene_names and gene_uniprotIDs
    nodesA <- dplyr::select(ptms, c(.data$enzyme_genesymbol, .data$enzyme))
    nodesB <- 
        dplyr::select(ptms, c(.data$substrate_genesymbol, .data$substrate))
    colnames(nodesA) = colnames(nodesB) = c("genesymbol", "up_id")
    nodes <- rbind(nodesA,nodesB)
    nodes <- unique(nodes)
    nodes <- nodes %>% dplyr::group_by(.data$genesymbol) %>% 
    dplyr::summarise("up_ids" = paste0(.data$up_id,collapse=",")) %>% 
    dplyr::ungroup()

    op_dfs <- list(edges = edges, nodes = nodes)
    directed = TRUE

    op_g <- igraph::graph_from_data_frame(d = op_dfs$edges,directed = directed,
        vertices = op_dfs$nodes)

    igraph::E(op_g)$sources    <- strsplit(igraph::E(op_g)$sources,    ';')
    igraph::E(op_g)$references <- strsplit(igraph::E(op_g)$references, ';')
    return(op_g)
}

#' Build Omnipath interaction graph
#'
#' transforms the interactions data.frame to an igraph object
#'
#' @return An igraph object
#' @export
#' @import igraph
#' @importFrom dplyr %>% select group_by summarise ungroup
#' @param interactions data.frame created by 
#' \code{\link{import_Omnipath_Interactions}},
#' \code{\link{import_PathwayExtra_Interactions}}, 
#' \code{\link{import_KinaseExtra_Interactions}},
#' \code{\link{import_LigrecExtra_Interactions}}, 
#' \code{\link{import_TFregulons_Interactions}},
#' \code{\link{import_miRNAtarget_Interactions}} or 
#' \code{\link{import_AllInteractions}} 
#' @examples
#' interactions = import_Omnipath_Interactions(filter_databases=c("SignaLink3"))
#' OPI_g = interaction_graph(interactions)
#' @seealso \code{\link{import_Omnipath_Interactions}},
#' \code{\link{import_PathwayExtra_Interactions}}, 
#' \code{\link{import_KinaseExtra_Interactions}},
#' \code{\link{import_LigrecExtra_Interactions}}, 
#' \code{\link{import_TFregulons_Interactions}},
#' \code{\link{import_miRNAtarget_Interactions}} or 
#' \code{\link{import_AllInteractions}} 
interaction_graph <- function(interactions = interactions){
    # This is a gene_name based conversion to igraph, i.e. the vertices are 
    # identified by genenames, and not by uniprot IDs.
    # This might cause issue when a gene name encodes multiple uniprot IDs.

    # keep only edge attributes
    edges <- interactions %>% dplyr::select(- c(.data$source, .data$target))

    # build vertices: gene_names and gene_uniprotIDs
    nodesA <- 
        dplyr::select(interactions, c(.data$source_genesymbol,.data$source))
    nodesB <- 
        dplyr::select(interactions, c(.data$target_genesymbol,.data$target))
    colnames(nodesA) = colnames(nodesB) = c("genesymbol", "up_id")
    nodes <- rbind(nodesA,nodesB)
    nodes <- unique(nodes)
    nodes <- nodes %>% dplyr::group_by(.data$genesymbol) %>% 
    dplyr::summarise("up_ids" = paste0(.data$up_id,collapse=",")) %>% 
    dplyr::ungroup()
    
    op_dfs <- list(edges = edges,nodes = nodes)
    directed <- TRUE
    op_g <- igraph::graph_from_data_frame(d = op_dfs$edges,directed = directed,
        vertices = op_dfs$nodes)

    igraph::E(op_g)$sources  <- strsplit(igraph::E(op_g)$sources,';')
    
    if ("references" %in% colnames(interactions)){
        igraph::E(op_g)$references <- strsplit(igraph::E(op_g)$references, ';')
    }
    return(op_g)
}

