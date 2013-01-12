/*
*/

g_project_instance		<-	0

class	ProjectHandler
{
	dispatch				=	0
	scene_filename			=	"scenes/screen_game.nms"
	scene					=	0

	function	OnUpdate(project)
	{
		dispatch(project)
	}

	function	OnSetup(project)
	{
		g_project_instance = ProjectGetScriptInstance(project)
		print("ProjectHandler::OnSetup()")
	}

	function	LoadScene(project)
	{
		if (scene != 0)	ProjectUnloadScene(project, scene)

		if (FileExists(scene_filename))
		{
			print("ProjectHandler::LoadScene('" + scene_filename + "')")
			scene = ProjectInstantiateScene(project, scene_filename)
			ProjectAddLayer(project, scene, 0.5)
		}
		else
			error("ProjectHandler::LoadNextTest() Could not find '" + scene_filename + "'.")

		dispatch = MainUpdate
	}
	
	function	MainUpdate(project)
	{
	}
	
	constructor()
	{
		print("ProjectHandler::constructor()")
		dispatch =  LoadScene
	}
}
