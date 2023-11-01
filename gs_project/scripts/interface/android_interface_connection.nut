
g_AndroidInterfaceConnection <- 0

/*!
	@short	android_interface_connection
	@author	Scorpheus
*/
class	android_interface_connection
{
		/////////////////////////////////////////////////////////////////////////////////

	
	function SendFormToAndroid()
	{
		// serialize the window
		local string_window = g_WindowsManager.SerializationSave()
		
		// send it to the android		
		g_NetworkManager.AppendUrlRequest(this, "", "http://212.51.180.186:22056/simu/?client=s&type=save", string_window)		
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	
	function RequestFromAndroid(_data, _error)
	{
		if (typeof _data != "string" || _data == null)
			_data = ""
						
		//print("Receive from the android : "+_data)
		
		if(_error)
			print("ARGGG error on retrieve android")			
		
		if(!_error && _data.len() > 0 && _data.find("FAIL") == null)
		{
			if(_data == "IAMEMPTY")
			{
				SendFormToAndroid()
			}
			else
			{
				local ArrayStringFunc = compilestring("{return "+_data+"}")
				local _Array = ArrayStringFunc(ArrayStringFunc)
				
				foreach(val in _Array)
				{
					if("value" in val)
						g_WindowsManager.CallCallback(val.id.tointeger(), val.value)
					else
						g_WindowsManager.CallCallback(val.id.tointeger())
				}			
			}
		}
	}
	
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		
	}	
	
	
	/*!
		@short	Refresh
		when lose the context
	*/
	function	Refresh()
	{
	}


	/*!
		@short	OnExitScene
		Clean everything
	*/
	function OnExitScene()
	{
		g_AndroidConnection = 0
	}	
	
	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{					
		g_AndroidInterfaceConnection = this
		
		// Create a url request timer to check if the simu want some change 
		if(g_NetworkManager)
		{
			g_NetworkManager.AppendTimerUrlRequest(g_AndroidInterfaceConnection, "RequestFromAndroid", 2.0, "http://212.51.180.186:22056/simu/?client=s&type=ask", "youpi")			
		}
	}
}

