########## ########## ########## ##########
########## PTMS                  ##########   
########## ########## ########## ##########

#' Import Omnipath post-translational modifications (PTMs)
#'
#' imports the PTMs database from \url{http://omnipathdb.org/ptms}
#'
#' @return A data frame containing the information about ptms
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases PTMs not reported in these databases are 
#' removed. See \code{\link{.get_ptms_databases}} for more information
#' @param select_organism PTMs are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' @examples
#' ptms = import_Omnipath_PTMS(filter_databases=c("PhosphoSite", "Signor"),
#'        select_organism=9606)
#'        
#' @seealso \code{\link{.get_ptms_databases}, 
#'   \link{import_Omnipath_Interactions}}         
import_Omnipath_PTMS = function (from_cache_file=NULL,
    filter_databases = .get_ptms_databases(),select_organism = 9606){

    url_ptms_common <- 
        'http://omnipathdb.org/ptms/?fields=sources&fields=references'

    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url_ptms <- paste0(url_ptms_common,'&genesymbols=1') 
        } else {
            if (select_organism == 10116){
                url_ptms <- 
                    paste0(url_ptms_common,'&genesymbols=1&organisms=10116') 
            }
            if (select_organism == 10090){
                url_ptms <- 
                    paste0(url_ptms_common,'&genesymbols=1&organisms=10090') 
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        ptms <- getURL(url_ptms, read.table, sep = '\t', header = TRUE,
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(ptms), " PTMs"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredPTMS <- .filter_sources(ptms,databases = filter_databases)
    } else {
        filteredPTMS <- ptms
    }
    filteredPTMS$residue_offset <- 
        as.character(as.numeric(filteredPTMS$residue_offset))

    filteredPTMS$sources <- as.character(filteredPTMS$sources)
    filteredPTMS$references <- as.character(filteredPTMS$references)
    # we remove references mentioned multiple times:
    filteredPTMS$references <- 
        unlist(lapply(strsplit(filteredPTMS$references,split = ";"),
        function(x)paste(unique(x),collapse=";")))
    filteredPTMS$nsources <-
        unlist(lapply(strsplit(filteredPTMS$sources,split = ";"),length))
    filteredPTMS$nrefs <-
        unlist(lapply(strsplit(filteredPTMS$references,split = ";"),length))
    return(filteredPTMS)
}

#' Get Post-translational modification (PTMs) databases
#'
#' get the names of the different databases available for ptms databases 
#' \url{http://omnipath.org/ptms}
#' 
#' @return character vector with the names of the PTMs databases
#' @export
#' @importFrom utils read.table
#' @examples
#' .get_ptms_databases()
#' @seealso  \code{\link{import_Omnipath_PTMS}} 
.get_ptms_databases = function(){
    url_ptms <- 'http://omnipathdb.org/ptms/?fields=sources'
    ptms <- getURL(url_ptms, read.table, sep = '\t', header = TRUE,
        stringsAsFactors = FALSE)
    return(unique(unlist(strsplit(x = as.character(ptms$sources),split = ";"))))
}

########## ########## ########## ##########
########## INTERACTIONS          ##########   
########## ########## ########## ##########

## Import Omnipath interaction Database. The new version of Ominpath contains 
## several different datastes. 

#' Import Omnipath interaction database
#'
#' imports the database from \url{http://omnipathdb.org/interactions}, which 
#' contains only interactions with references. These interactions are the 
#' original ones from the first Omnipath version. 
#' 
#' @return A dataframe containing information about protein-protein interactions
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' 
#' @examples
#' interactions = import_Omnipath_Interactions(filter_databases=c("SignaLink3"),
#'                select_organism = 9606)
#'                
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}                 
import_Omnipath_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(),select_organism = 9606){

    url_common <- 
        'http://omnipathdb.org/interactions?fields=sources&fields=references'
    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- paste0(url_common,'&genesymbols=1')
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,'&genesymbols=1&organisms=10116')
            }
            if (select_organism == 10090){
                url <- paste0(url_common,'&genesymbols=1&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url,read.table,sep = '\t', header = TRUE,
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <- 
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$references<-
        as.character(filteredInteractions$references)
    ## we remove references mentioned multiple times:
    filteredInteractions$references <-
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        function(x)paste(unique(x),collapse=";")))
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))
    filteredInteractions$nrefs <-
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        length))

    return(filteredInteractions)
}


#' Imports from Omnipath webservice the interactions from 
#' Pathwayextra dataset
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=pathwayextra}, 
#' which contains activity flow interactions without literature reference
#' 
#' @return A dataframe containing activity flow interactions between proteins
#' without literature reference
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose one of those: 9606 human (default), 10116 rat or 10090 Mouse
#' @examples
#' interactions <- 
#'     import_PathwayExtra_Interactions(filter_databases=c("BioGRID","IntAct"),
#'      select_organism = 9606)
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}
import_PathwayExtra_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(),select_organism = 9606){

    url_common <- paste0('http://omnipathdb.org/interactions?datasets=',
        'pathwayextra&fields=sources')  

    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- paste0(url_common,'&genesymbols=1')
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,'&genesymbols=1&organisms=10116')
            }
            if (select_organism == 10090){
                url <- paste0(url_common,'&genesymbols=1&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url,read.table,sep = '\t', header = TRUE, 
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <- 
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))
    
    return(filteredInteractions)
}

#' Imports from Omnipath webservice the interactions from 
#' kinaseextra dataset
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=kinaseextra}, 
#' which contains enzyme-substrate interactions without literature reference
#' 
#' @return A dataframe containing enzyme-substrate interactions without 
#' literature reference
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' 
#' @examples
#' interactions <- 
#'    import_KinaseExtra_Interactions(filter_databases=c("PhosphoPoint",
#'    "PhosphoSite"), select_organism = 9606)
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}          
import_KinaseExtra_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(),select_organism = 9606){

    url_common <- 
        'http://omnipathdb.org/interactions?datasets=kinaseextra&fields=sources'

    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- paste0(url_common,'&genesymbols=1')
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,'&genesymbols=1&organisms=10116')
            }
            if (select_organism == 10090){
                url <- paste0(url_common,'&genesymbols=1&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url,read.table,sep = '\t', header = TRUE,
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <-
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))

    return(filteredInteractions)
}


#' Imports from Omnipath webservice the interactions from 
#' ligrecextra dataset
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=ligrecextra}, 
#' which contains ligand-receptor interactions without literature reference
#' 
#' @return A dataframe containing ligand-receptor interaction without literature
#' reference
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' @examples
#' interactions <- import_LigrecExtra_Interactions(filter_databases=c("HPRD",
#'       "Guide2Pharma"), select_organism=9606)
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}
import_LigrecExtra_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(), select_organism=9606){

    url_common <- 
        'http://omnipathdb.org/interactions?datasets=ligrecextra&fields=sources'
    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- paste0(url_common,'&genesymbols=1')
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,'&genesymbols=1&organisms=10116')
        }
            if (select_organism == 10090){
                url <- paste0(url_common,'&genesymbols=1&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url, read.table ,sep = '\t', header = TRUE, 
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <- 
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))
    return(filteredInteractions)
}


#' Imports from Omnipath webservice the interactions from 
#' Dorothea dataset
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=tfregulons} 
#' which contains transcription factor (TF)-target interactions from DoRothEA
#' \url{https://github.com/saezlab/DoRothEA}
#' 
#' @return A dataframe containing TF-target interactions from DoRothEA
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' @examples
#' interactions <- import_TFregulons_Interactions(filter_databases=c("tfact",
#'     "ARACNe-GTEx"), select_organism=9606)
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}
import_TFregulons_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(),select_organism=9606){

    url_common <-
        'http://omnipathdb.org/interactions?datasets=tfregulons&fields=sources'
    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- paste0(url_common,',tfregulons_level&genesymbols=1')
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,
                    ',tfregulons_level&genesymbols=1&organisms=10116')
            }
            if (select_organism == 10090){
                url <- paste0(url_common,
                    ',tfregulons_level&genesymbols=1&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url, read.table, sep = '\t', header = TRUE, 
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <- .filter_sources(interactions,
            databases = filter_databases)
    } else { 
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))

    return(filteredInteractions)
}


#' Imports from Omnipath webservice the interactions from 
#' miRNAtarget dataset
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=mirnatarget}, 
#' which contains miRNA-mRNA and TF-miRNA interactions
#' 
#' @return A dataframe containing miRNA-mRNA and TF-miRNA interactions
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @examples
#' interactions <- 
#'   import_miRNAtarget_Interactions(filter_databases=c("miRTarBase",
#'   "miRecords"))
#' @seealso \code{\link{.get_interaction_databases}, 
#'   \link{import_AllInteractions}}
import_miRNAtarget_Interactions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases()){

    url <- paste0('http://omnipathdb.org/interactions?datasets=mirnatarget',
        '&fields=sources,references&genesymbols=1') 

    if(is.null(from_cache_file)){
        interactions <- getURL(url, read.table, sep = '\t', header = TRUE, 
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <- 
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))
    filteredInteractions$references <-
        as.character(filteredInteractions$references)
# we remove references mentioned multiple times:
    filteredInteractions$references <-
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        function(x)paste(unique(x),collapse=";")))
    filteredInteractions$nrefs <-
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        length))

    return(filteredInteractions)
}


#' Imports from Omnipath webservice all the available interactions 
#' from the different datasets
#'
#' Imports the dataset from: 
#' \url{http://omnipathdb.org/interactions?datasets=omnipath,pathwayextra,
#' kinaseextra,ligrecextra,tfregulons,mirnatarget&fields=sources,
#' references&genesymbols=1}, 
#' which contains all the different interactions available in the webserver:
#' 
#' omnipath: the OmniPath data as defined in the paper, an arbitrary optimum 
#' between coverage and quality
#' pathwayextra: activity flow interactions without literature reference
#' kinaseextra: enzyme-substrate interactions without literature reference
#' ligrecextra: ligand-receptor interactions without literature reference
#' tfregulons: transcription factor (TF)-target interactions from DoRothEA
#' mirnatarget: miRNA-mRNA and TF-miRNA interactions
#' 
#' @return A dataframe containing all the datasets in the interactions query
#' @export
#' @importFrom utils read.table
#' @param from_cache_file path to an earlier data file
#' @param filter_databases interactions not reported in these databases are 
#' removed. See \code{\link{.get_interaction_databases}} for more information.
#' @param select_organism Interactions are available for human, mouse and rat. 
#' Choose among: 9606 human (default), 10116 rat and 10090 Mouse
#' @examples
#' interactions <- import_AllInteractions(filter_databases=c("HPRD","BioGRID"),
#'     select_organism = 9606)
#' @seealso \code{\link{.get_interaction_databases}}
import_AllInteractions = function (from_cache_file=NULL,
    filter_databases = .get_interaction_databases(),select_organism = 9606){

    url_common <- paste0('http://omnipathdb.org/interactions?datasets=omnipath',
        ',pathwayextra,kinaseextra,ligrecextra,tfregulons,mirnatarget', 
        '&fields=sources,references&genesymbols=1')

    if (select_organism %in% c(9606, 10116, 10090)){
        if (select_organism == 9606){
            url <- url_common
        } else {
            if (select_organism == 10116){
                url <- paste0(url_common,'&organisms=10116')
            }
            if (select_organism == 10090){
                url <- paste0(url_common,'&organisms=10090')
            }
        }     
    } else {
        stop("The selected organism is not correct")
    }

    if(is.null(from_cache_file)){
        interactions <- getURL(url, read.table, sep = '\t', header = TRUE, 
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(interactions), " interactions"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredInteractions <-
            .filter_sources(interactions,databases = filter_databases)
    } else {
        filteredInteractions <- interactions
    }

    filteredInteractions$sources <- as.character(filteredInteractions$sources)
    filteredInteractions$nsources <-
        unlist(lapply(strsplit(filteredInteractions$sources,split = ";"),
        length))
    filteredInteractions$references <- 
        as.character(filteredInteractions$references)
## we remove references mentioned multiple times:
    filteredInteractions$references <- 
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        function(x)paste(unique(x),collapse=";")))
    filteredInteractions$nrefs <-
        unlist(lapply(strsplit(filteredInteractions$references,split = ";"),
        length))

    return(filteredInteractions)
}

#' Get the different interaction databases
#'
#' get the names of the databases from \url{http://omnipath.org/interactions}
#' 
#' @return character vector with the names of the interaction databases
#' @export
#' @importFrom utils read.table
#' @examples
#' .get_interaction_databases()
#' @seealso \code{\link{import_AllInteractions}, 
#' \link{import_Omnipath_Interactions}, \link{import_PathwayExtra_Interactions},
#' \link{import_KinaseExtra_Interactions}, 
#' \link{import_LigrecExtra_Interactions},
#' \link{import_miRNAtarget_Interactions}, 
#' \link{import_TFregulons_Interactions}}
.get_interaction_databases = function(){
    url_interactions <- paste0('http://omnipathdb.org/interactions?',
        'datasets=omnipath,pathwayextra,kinaseextra,ligrecextra',
        ',tfregulons,mirnatarget&fields=sources')
    interactions <- getURL(url_interactions, read.table, sep = '\t', 
        header = TRUE,stringsAsFactors = FALSE)
    return(unique(unlist(strsplit(x = as.character(interactions$sources),
        split = ";"))))
}

########## ########## ########## ##########
########## Complexes             ##########   
########## ########## ########## ##########

#' Import Omnipath Complexes
#'
#' imports the complexes stored in Omnipath database from 
#' \url{http://omnipathdb.org/complexes}
#'
#' @return A dataframe containing information about complexes
#' @export
#' @importFrom utils read.csv
#' @param from_cache_file path to an earlier data file
#' @param filter_databases complexes not reported in these databases are 
#' removed. See \code{\link{.get_complexes_databases}} for more information.
#' @examples
#' complexes = import_Omnipath_complexes(filter_databases=c("CORUM", "hu.MAP"))
#' @seealso \code{\link{.get_complexes_databases}}
import_Omnipath_complexes = function (from_cache_file=NULL,
    filter_databases = .get_complexes_databases()){

    url_complexes <- 'http://omnipathdb.org/complexes?&fields=sources'

    if(is.null(from_cache_file)){
        complexes <- getURL(url_complexes, read.csv, sep = '\t', header = TRUE,
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(complexes), " complexes"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredcomplexes <- .filter_sources(complexes,
            databases = filter_databases)
    } else {
        filteredcomplexes <- complexes
    }

    filteredcomplexes$sources <- as.character(filteredcomplexes$sources)
    filteredcomplexes$references <- as.character(filteredcomplexes$references)
    # we remove references mentioned multiple times:
    filteredcomplexes$references <-
        unlist(lapply(strsplit(filteredcomplexes$references,split = ";"),
        function(x)paste(unique(x),collapse=";")))
    filteredcomplexes$nsources <-
        unlist(lapply(strsplit(filteredcomplexes$sources,split = ";"),length))
    filteredcomplexes$nrefs <-
        unlist(lapply(strsplit(filteredcomplexes$references,split = ";"),
        length))

    return(filteredcomplexes)
}


#' Get the different complexes databases integrated in Omnipath
#'
#' get the names of the databases from \url{http://omnipath.org/complexes}
#' @return character vector with the names of the databases
#' @export
#' @importFrom utils read.csv
#' @examples
#' .get_complexes_databases()
#' @seealso \code{\link{import_Omnipath_complexes}}
.get_complexes_databases = function(){
    url_complexes <- 'http://omnipathdb.org/complexes?&fields=sources'
    complexes <- getURL(url_complexes, read.csv, sep = '\t', header = TRUE,
        stringsAsFactors = FALSE)
    return(unique(unlist(strsplit(x = as.character(complexes$sources),
        split = ";"))))
}

########## ########## ########## ##########
########## Annotations           ##########   
########## ########## ########## ##########

#' Import Omnipath Annotations
#'
#' imports the annotations stored in Omnipath database from 
#' \url{http://omnipathdb.org/annotations}
#'
#' @return A data.frame containing different gene/complex annotations
#' @export
#' @importFrom utils read.csv
#' @param from_cache_file path to an earlier data file
#' @param select_genes vector containing the genes for whom annotations will be
#' retrieved (hgnc format). It is also possible to donwload complexes 
#' annotations. To do so, write "COMPLEX:" right before the genesymbols of
#' the genes integrating the complex. Check the vignette for examples. 
#' @param filter_databases annotations not reported in these databases are 
#' removed. See \code{\link{.get_annotation_databases}} for more information.
#' @examples
#' annotations = import_Omnipath_annotations(select_genes=c("TP53","LMNA"),
#'      filter_databases=c("HPA"))
#' @seealso \code{\link{.get_annotation_databases}}       
import_Omnipath_annotations = function (from_cache_file=NULL,
    select_genes = NULL, filter_databases = .get_annotation_databases()){

    url_annotations <- 'http://omnipathdb.org/annotations?&proteins='
    
    if(is.null(select_genes)){
        stop("A vector of genes should be provided")
    } else {
        genes_query <- paste0(select_genes,collapse = ",")
        url_annotations <- paste0(url_annotations,genes_query)
    }

    if(is.null(from_cache_file)){
        annotations <- getURL(url_annotations, read.csv, sep = '\t', 
            header = TRUE, stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(annotations), " annotations"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(filter_databases)){
        filteredannotations <- .filter_sources_annotations(annotations,
            databases = filter_databases)
    } else {
        filteredannotations <- annotations
    }

    return(filteredannotations)
}


#' Get the different annotation databases integrated in Omnipath
#'
#' get the names of the databases from \url{http://omnipath.org/annotation}
#' 
#' @return character vector with the names of the annotation databases
#' @export
#' @examples
#' .get_annotation_databases()
#' @seealso \code{\link{import_Omnipath_annotations}}
.get_annotation_databases = function(){
    url_annotations <- 'http://omnipathdb.org/annotations_summary'
    annotations <- getURL(url_annotations, read.table, sep = '\t', 
        header = TRUE,stringsAsFactors = FALSE)

    annotations_db <- unique(annotations$source)
    return(annotations_db)
}


########## ########## ########## ##########
########## Intercell             ##########   
########## ########## ########## ##########

#' Import Omnipath Intercell Data
#'
#' imports the intercell data stored in Omnipath database from 
#' \url{http://omnipathdb.org/intercell}. Intercell provides 
#' information on the roles in inter-cellular signaling. E.g. if a protein is 
#' a ligand, a receptor, an extracellular matrix (ECM) component, etc.
#'
#' @return A dataframe cotaining information about roles in inter-cellular
#' signaling. 
#' @export
#' @importFrom utils read.csv
#' @param from_cache_file path to an earlier data file
#' @param select_categories vector containing the categories to be retrieved.
#' All the genes belonging to that category will be returned. For furter 
#' information about the categories see \code{\link{.get_intercell_categories}} 
#' @examples
#' intercell = import_Omnipath_intercell(select_categories=c("ecm"))
#' @seealso \code{\link{.get_intercell_categories}} 
import_Omnipath_intercell = function (from_cache_file=NULL,
    select_categories = .get_intercell_categories()){

    url_intercell <- 'http://omnipathdb.org/intercell'

    if(is.null(from_cache_file)){
        intercell <- getURL(url_intercell, read.csv, sep = '\t', header = TRUE,
            stringsAsFactors = FALSE)
        print(paste0("Downloaded ", nrow(intercell), " intercell records"))
    } else {
        load(from_cache_file)
    }

    if(!is.null(select_categories)){
        filteredintercell <- .filter_categories_intercell(intercell,
            select_categories)
    } else {
        filteredintercell <- intercell
    }

    return(filteredintercell)
}


#' Get the different intercell categories described in Omnipath
#'
#' get the names of the categories from \url{http://omnipath.org/intercell}
#' @return character vector with the different intercell categories
#' @export
#' @importFrom utils read.csv
#' @examples
#' .get_intercell_categories()
#' @seealso \code{\link{import_Omnipath_intercell}}
.get_intercell_categories = function(){

    url_intercell <- 'http://omnipathdb.org/intercell'
    intercell <- getURL(url_intercell, read.csv, sep = '\t', header = TRUE,
        stringsAsFactors = FALSE)

    return(unique(intercell$category))
}

########## ########## ########## ##########
########## SOURCE FILTERING      ##########   
########## ########## ########## ##########
## Non exported functions (package internal functions) to filter PTMs,
## interactions, complexes and annotations according to the databases passed
## to the main functions

## Filtering Interactions, PTMs and complexes
.filter_sources = function(interactions, databases){

    nInter = nrow(interactions)

    subsetInteractions <- 
        interactions[which(unlist(lapply(strsplit(interactions$sources,";"),
        function(x){any(x %in% databases)}))),]

    nInterPost = nrow(subsetInteractions)

    print(paste0("removed ",nInter-nInterPost,
        " interactions during database filtering."))
    return(subsetInteractions)
}


## Filtering Annotations
.filter_sources_annotations = function(annotations, databases){
## takes annotations and removes those which are
## not reported by the given databases.

    nAnnot = nrow(annotations)
    subsetAnnotations <- dplyr::filter(annotations, source %in% databases)
    nAnnotPost = nrow(subsetAnnotations)

    print(paste0("removed ",nAnnot-nAnnotPost,
        " annotations during database filtering."))

    if (nAnnotPost > 0){
        return(subsetAnnotations)
    } else {
        return(NULL)
    }
}

## Filtering intercell records according to the categories selected
.filter_categories_intercell = function(intercell, categories){
## takes intercell removes and removes those not reported by the given 
## databases
    nIntercell = nrow(intercell)
    subsetIntercell <- dplyr::filter(intercell, .data$category %in% categories)
    nIntercellPost = nrow(subsetIntercell)

    print(paste0("removed ",nIntercell-nIntercellPost, 
        " intercell records during category filtering."))

    if (nIntercellPost > 0){
        return(subsetIntercell)
    } else {
        return(NULL)
    }
}

########## ########## ########## ##########
########## Resource Queries      ##########   
########## ########## ########## ##########
## This function is convenient for appropriate resource retrieval. Following:
## http://bioconductor.org/developers/how-to/web-query/
## It tries to retrieve the resource one or several times before failing.
getURL <- function(URL, FUN, ..., N.TRIES=1L) {
    N.TRIES <- as.integer(N.TRIES)
    stopifnot(length(N.TRIES) == 1L, !is.na(N.TRIES))

    while (N.TRIES > 0L) {
        result <- tryCatch(FUN(URL, ...), error=identity)
        if (!inherits(result, "error"))
            break
            N.TRIES <- N.TRIES - 1L
        }

    if (N.TRIES == 0L) {
        stop("'getURL()' failed:",
            "\n  URL: ", URL,
            "\n  error: ", conditionMessage(result))
    }

    return(result) 
}


