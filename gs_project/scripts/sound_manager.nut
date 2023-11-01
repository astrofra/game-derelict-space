
class	AudioChannel
{
	sound = 0
	channel			=	0
	gain			=	0
	pitch			=	0
	prev_gain		=	0
	prev_pitch		=	0

	target_gain		=	0
	target_pitch	=	0

	/*	ADSR Model
		v
		^
		|
		|A /\D  S
		| /  \_____
		|/         \ R
		+----------------> t
	*/

	volume			=	0
	clock			=	0
	attack_time		=	0
	decay_time		=	0
	sustain_level	=	0
	sustain_time	=	0
	release_time	=	0

	constructor(_sound)
	{
		sound = _sound
		channel			=	0
		gain			=	0
		pitch			=	1.0
		prev_gain		=	0
		prev_pitch		=	1.0

		target_gain		=	0
		target_pitch	=	1.0

		channel = MixerChannelLock(g_mixer)
		MixerChannelStart(g_mixer, channel, sound)
		MixerChannelSetGain(g_mixer, channel, gain)
		MixerChannelSetPitch(g_mixer, channel, pitch)
		MixerChannelSetLoopMode(g_mixer, channel, LoopRepeat)
		clock = 0.0
		print("AudioChannel::constructor() allocated the channel #" + channel.tostring() + ".")

		volume			=	1.0
		clock			=	0.0
		attack_time		=	0.0
		decay_time		=	0.0
		sustain_level	=	0.5
		sustain_time	=	-1.0
		release_time	=	0.0
	}

	function	SetGain(_gain)
	{	target_gain = _gain	}

	function	SetPitch(_pitch)
	{	target_pitch = _pitch	}

	function	SetADSR(a,d,s_level,s,r)
	{
		attack_time = a
		decay_time = d
		sustain_time = s
		sustain_level = s_level
		release_time = r
	}

	function	PlayNote(pitch, _gain = 1.0)
	{
		this.SetGain(_gain)
		this.SetPitch(pitch)
		clock = 0.0
	}

	function	Update()
	{
		gain = target_gain * volume
		pitch = target_pitch
		if (gain != prev_gain)	MixerChannelSetGain(g_mixer, channel, gain)
		if (pitch != prev_pitch)	MixerChannelSetPitch(g_mixer, channel, pitch)
		prev_gain = gain
		prev_pitch = pitch
	//	EvaluateADSR()
	//	clock += g_dt_frame
	}

	function	EvaluateADSR()
	{
		if (clock < attack_time)
			volume = Clamp(RangeAdjust(clock, 0.0, attack_time, 0.0, 1.0), 0.0, 1.0)
		else
		if (clock < decay_time)
			volume = Clamp(RangeAdjust(clock, attack_time, decay_time, 1.0, sustain_level), sustain_level, 1.0)
		else
		if ((clock < sustain_time) || (sustain_time == -1))
			volume = sustain_level
		else
		if (sustain_time != -1)
			volume = Clamp(RangeAdjust(clock, sustain_time, release_time, sustain_level, 0.0), 0.0, sustain_level)
	}

}


/*!
	@short	SoundManager
	@author	thomas	
*/
class	SoundManager
{
	channels	=	0

	constructor()
	{
		channels = []
	}

	function	StartSound(sound)		// sound come from ResourceFactoryLoadSound(g_factory, "yeepeee.wave")
	{
		if(sound == 0)
			return 0

		local	new_channel = AudioChannel(sound)
		channels.append(new_channel)
		return 	new_channel
	}
	
	/*!
		@short	Update
		Called each frame.
	*/
	function	Update()
	{
		foreach(chan in channels)
			chan.Update()		
	}

	/*!
		@short	remove
	*/
	function	RemoveSound(_channel)
	{
		local id_channel = -1
		foreach(id, chan in channels)
		{			
			if(chan == _channel)
			{
				id_channel = id
				chan.SetGain(0.0)
				chan.Update()	
				MixerChannelStop(g_mixer, chan.channel)
				MixerChannelUnlock(g_mixer, chan.channel)
			}
		}

		if(id_channel != -1)
			channels.remove(id_channel)
	}

	/*!
		@short	Kill
	*/
	function	Kill()
	{
		foreach(chan in channels)
		{
			chan.SetGain(0.0)
			chan.Update()	
			MixerChannelStop(g_mixer, chan.channel)
			MixerChannelUnlock(g_mixer, chan.channel)
		}
		MixerChannelStopAll(g_mixer)

		channels.clear()
		MixerChannelUnlockAll(g_mixer)
	}

	/*!
		@short	Setup
		Called when the scene is about to be setup.
	*/
	function	Setup()
	{
		
	}
}
