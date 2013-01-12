/*
	File: scripts/utils/scene_game.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	SceneGame
	@author	P. Blanche - F. Gutherz
*/
class	SceneGameBase
{
	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		SceneSetGravity(scene, Vector(0,0,0))
	}
}
