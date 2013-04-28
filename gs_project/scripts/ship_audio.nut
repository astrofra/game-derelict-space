/*
	File: scripts/ship_audio.nut
	Author: P. Blanche - F. Gutherz
*/

/*!
	@short	ShipAudio
	@author	P. Blanche - F. Gutherz
*/
class	ShipAudio
{
	variables				=	0
	samples					=	0
	channels				=	0

	function	Delete()
	{
		foreach(_chan in channels)
			MixerChannelStop(g_mixer, _chan)

		foreach(_sample in samples)
			_sample = 0

		channels = 0
		samples = 0
	}

	function	Update()
	{
		local	_speed = RangeAdjust(max(fabs(variables.thrust), fabs(variables.thrust_strafe)), 0.0, variables.max_thrust, 0.0, 1.0)
		local	_gain = Clamp(_speed, 0.1, 1.0)
		local	_pitch = Clamp(RangeAdjust(_speed, 0.0, 1.0, 0.8, 1.2), 0.8, 1.2)
		MixerChannelSetGain(g_mixer, channels["ship_reactor"], _gain)
		MixerChannelSetPitch(g_mixer, channels["ship_reactor"], _pitch)
	}

	function	SfxSetOrientationTarget()
	{
		local	_chan = MixerSoundStart(g_mixer, samples["gui_up_down"])
		MixerChannelSetGain(g_mixer, _chan, 0.25)
	}

	function	PushVariable(_key_str = "MyVariableKey", _value = 0.0)
	{
		if (_key_str in variables)
			variables[_key_str] = _value
		else
			variables.rawset(_key_str, _value)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	constructor()
	{
		samples = {}
		channels = {}
		variables = {}

		LoadSample("ship_reactor")
		channels.rawset("ship_reactor", MixerSoundStart(g_mixer, samples["ship_reactor"]))
		MixerChannelSetLoopMode(g_mixer, channels["ship_reactor"], LoopRepeat)
		LoadSample("ship_strafe")
		LoadSample("gui_up_down")
	}

	//---------	
	//	Private
	//---------

	function	LoadSample(_filename)
	{
		local	_fname = "sfx/" + _filename + ".wav"
		if (FileExists(_fname))
			samples.rawset(_filename, ResourceFactoryLoadSound(g_factory, _fname))
	}


}
