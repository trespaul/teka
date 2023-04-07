import Options.Applicative

data MainOptions = MainOptions 
  { format :: Maybe String -- TODO: make enum
  , config :: Maybe FilePath
  , mainCommand :: Command
  } deriving Show 

data Command
  = Add    { files :: [String] }
  | Remove { queryOrIDs :: [String] }
  | Export { queryOrIDs :: [String], annotations :: Bool }
  | Search { searchString :: String, fulltext :: Bool }
  | Query  { query :: String }
  | Edit   { queryOrIDs :: [String] }
  | Attach { recordID :: String, file :: String, description :: Maybe String }
  | Open   { recordID :: String, attachmentID :: Maybe String }
    deriving Show

-- data Format
--   = Json | Yaml | Bib | Doi | Url
--   deriving Show

mainParser :: Parser MainOptions
mainParser = MainOptions
  <$> optional (strOption
        ( long "format"
       <> short 'f'
       <> help "The format of the input or output files. Can be JSON, YAML, BIB, DOI, or URL." 
       <> showDefault
       <> value "JSON"
       <> metavar "FORMAT"
        )
      )
  <*> optional (strOption
        ( long "config"
       <> short 'c'
       <> help "Specify config file."
       <> metavar "FILE"
        )
      )
  <*> commandParser

addSubParser :: Parser Command
addSubParser = Add
  <$> some
        ( argument str
            ( help "File(s) containing record(s) to add. If `-`, read from stdin."
           <> metavar "FILE(s)"
            )   
        )

removeSubParser :: Parser Command
removeSubParser = Remove
  <$> some -- TODO: make choice between IDs and QUERY (?)
        ( argument str
            ( help "Records to remove." 
           <> metavar "ID(s)|QUERY"
            )
        )

exportSubParser :: Parser Command
exportSubParser =  Export
  <$> some
        ( argument str
            ( help "Records to export."
           <> metavar "ID(s)|QUERY"
            )
        )
  <*> switch
        ( long "annotations"
       <> short 'a'
       <> help "Export annotations as well."
        )

searchSubParser :: Parser Command
searchSubParser = Search
  <$> argument str
        ( help "String for which to search."
       <> metavar "STRING"
        )
  <*> switch
        ( long "fulltext"
       <> help "Perform a fulltext search."
        )

querySubParser :: Parser Command
querySubParser = Query
  <$> argument str
        ( help "Query string to perform."
       <> metavar "QUERY"
        )

editSubParser :: Parser Command
editSubParser = Edit
  <$> some
        ( argument str
            ( help "Records to edit."
           <> metavar "ID(s)|QUERY"
            )
        )

attachSubParser :: Parser Command
attachSubParser = Attach
  <$> argument str
        ( help "ID of record to which FILE is to be attached."
       <> metavar "ID"
        )
  <*> argument str
        ( help "File to attach. URLs will be fetched."
       <> metavar "FILE"
        )
  <*> optional (option auto
        ( long "description"
       <> short 'd'
       <> help "Description of attachment."
       <> metavar "DESCRIPTION"
        )
      )

openSubParser :: Parser Command
openSubParser = Open
  <$> argument str
        ( help "Record to open."
       <> metavar "RECORD_ID"
        )
  <*> optional (argument str
        ( help "Attachment to open; will prompt if not provided."
       <> metavar "ATTACHMENT_ID"
        )
      )

commandParser :: Parser Command
commandParser = hsubparser
  ( command "add"
      ( info addSubParser
          ( progDesc "Add a record." )
      )
 <> command "remove"
      ( info removeSubParser
          ( progDesc "Remove record(s)." )
      )
 <> command "export"
      ( info exportSubParser
          ( progDesc "Export records." )
      )
 <> command "search"
      ( info searchSubParser
          ( progDesc "Search for a plain-text string.")
      )
 <> command "query"
      ( info querySubParser
          ( progDesc "Perform an SQL-like query.")
      )
 <> command "edit"
      ( info editSubParser
          ( progDesc "Edit record(s).")
      )
 <> command "attach"
      ( info attachSubParser
          ( progDesc "Attach a file to a record.")
      )
 <> command "open"
      ( info openSubParser
          ( progDesc "Open an attachment in the default program.")
      )
  )


main :: IO ()
main = run =<< customExecParser preferences opts
  where
    opts = info (helper <*> mainParser)
      ( fullDesc
     <> progDesc "bib on the cli"
     <> header "clibib"
      )
    preferences = prefs showHelpOnEmpty

run :: MainOptions -> IO ()
run = print
