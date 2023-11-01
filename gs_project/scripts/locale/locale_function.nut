g_current_language 	<- "french"
g_translation_db		<-	{}

function	SetupLocale()
{
}

function	tr(_keyword)
{
	if(_keyword in g_translation_db)
		return g_translation_db[_keyword]
	else
		return _keyword
}
	