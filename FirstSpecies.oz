% This file is a modification / extension of the Strasheela example provided in
% $STRASHEELA/exmaples/Counterpoint-Examples/Fuxian-Counterpoint-with-Scale.oz
%
% My goal is to write an implementation of four-voice strict counterpoint, or
% get as far as possible. I will base my rule set on the counterpoint course I
% have followed this year. At some point I will write up this rule set and my
% interpretation, together with my experiences. But for now, I am going to
% experiment a little.

declare
[ET12] = {ModuleLink ['x-ozlib://anders/strasheela/ET12/ET12.ozf']}

proc {FirstSpecies Args ?MyScore}
   % the cantus exercise in my counterpoint course, placed in a bass range
   CantusFirmus = {Map ['C'#3 'E'#3 'A'#3 'G'#3 'E'#3 'F'#3 'D'#3 'C'#3]
		   ET12.pitch}
   % restricting the domain of the counterpoint voice to an alto (alike) range
   CounterpointDomain = {ET12.pitch'C'#4}#{ET12.pitch 'G'#5}

   MyScale = {Score.makeScore scale(duration:4 startTime:0 transposition:0)
	      unit(scale:HS.score.scale)}
   
   CantusFirmusVoice = {MakeVoice CantusFirmus MyScale 'cantus firmus'}
   CounterpointVoice = {MakeVoice
			{FD.list {Length CantusFirmus} CounterpointDomain}
			MyScale 'counterpoint'}
in
   MyScore = {Score.makeScore sim(info:scale(MyScale)
				  items: [CounterpointVoice CantusFirmusVoice]
				  startTime: 0
				  timeUnit:beats)
	      unit}
   
   % place rules here
end

% create a voice based on a list of pitches, to be used in a Lilypond context
fun {MakeVoice Pitches MyScale VoiceName}
   {Score.makeScore2
    seq(info:lily("\\set Staff.instrumentName = \""#VoiceName#"\"")
	items: {Map Pitches fun {$ Pitch}
			       note(duration: 4
				    pitch: Pitch
				    inScaleB:{FD.int 0#1}
				    amplitude: 80)
			    end})
    add(note:HS.score.scaleNote)}
end

%
% Generate output
%
{GUtils.setRandomGeneratorSeed 0} % always find different solution
{SDistro.exploreOne {GUtils.extendedScriptToScript FirstSpecies
		     unit}
 unit(order:size
      value:random)}