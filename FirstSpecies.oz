% This file is a modification / extension of the Strasheela example provided in
% $STRASHEELA/examples/Counterpoint-Examples/Fuxian-Counterpoint-with-Scale.oz
%
% My goal is to write an implementation of four-voice strict counterpoint, or
% get as far as possible. I will base my rule set on the counterpoint course I
% have followed this year. At some point I will write up this rule set and my
% interpretation, together with my experiences. But for now, I am going to
% experiment a little.

declare
[ET12] = {ModuleLink ['x-ozlib://anders/strasheela/ET12/ET12.ozf']}

%
% the main procedure
%
proc {FirstSpecies Args ?MyScore}
   % the cantus exercise in my counterpoint course, placed in a bass range
   CantusFirmus = {Map ['C'#3 'E'#3 'A'#3 'G'#3 'E'#3 'F'#3 'D'#3 'C'#3]
		   ET12.pitch}
   % restricting the domain of the counterpoint voice to an alto range
   CounterpointDomain = {ET12.pitch'G'#3}#{ET12.pitch 'F'#5}

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
   {SetScaleRoot MyScale CantusFirmusVoice}
   % place rules here
   {OnlyDiatonicPitches CounterpointVoice}
   {RestrictMelodicIntervals CounterpointVoice}
   {StartAndEndWithPerfectConsonance CounterpointVoice}
end

%
% create a voice based on a list of pitches, to be used in a Lilypond context
%
fun {MakeVoice Pitches MyScale VoiceName}
   {Score.makeScore2
    seq(info:lily("\\set Staff.instrumentName = \""#VoiceName#"\"")
	items: {Map Pitches fun {$ Pitch}
			       note(duration: 4
				    pitch: Pitch
				    inScaleB:{FD.int 0#1}
				    getScales:proc {$ Self Scales} 
						 Scales = [MyScale]
					      end
				    isRelatedScale:proc {$ Self Scale B} B=1 end
				    amplitude: 80)
			    end})
    add(note:HS.score.scaleNote)}
end


%
% Scale database
%

MyScales = scales(1: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[0]
			   comment:'Ionian')
		  2: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[2]
			   comment:'Dorian')
		  3: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[4]
			   comment:'Phrygian')
		  4: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[5]
			   comment:'Lydian')
		  5: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[7]
			   comment:'Mixolydian')
		  6: scale(pitchClasses:[0 2 4 5 7 9 11]
			   roots:[9]
			   comment:'Aeolian'))

{HS.db.setDB unit(scaleDB:MyScales)}


%
% Helper functions
%

fun {GetScale Note}
   {Note getScales($)}.1
end

proc {SetScaleRoot MyScale CantusFirmus}
   {MyScale getRoot($)} = {{List.last {CantusFirmus getItems($)}}
			   getPitchClass($)}
end

% Returns the (single) note which is simultaneous to MyNote.
fun {GetSimultaneousNote MyNote}
   % getSimultaneousItems returns a list with the simultaneous items
   {MyNote getSimultaneousItems($ test:isNote)}.1
end

proc {GetInterval Note1 Note2 Interval}
   Interval = {FD.decl}
   {FD.distance {Note1 getPitch($)} {FD.plus {Note2 getPitch($)} 12} '=:' Interval}
end


%
% Rules
%

proc {OnlyDiatonicPitches Counterpoint}
   AllNotes = {Counterpoint getItems($)}
   PenultimateNote = {Nth AllNotes {Length AllNotes} - 1}
   AllButPenultimateNotes = {LUtils.remove AllNotes
			     fun {$ X} X == PenultimateNote end}
   ScaleIndex = {{GetScale PenultimateNote} getIndex($)}
in
   % in case of Dorian, Mixolydian or Aeolian mode we have to raise the
   % second-to-last note, in all other cases this is enforced by the mode
   thread
      if {Member ScaleIndex {Map ['Dorian' 'Mixolydian' 'Aeolian']
			     HS.db.getScaleIndex}}
      then {PenultimateNote getScaleAccidental($)} = {ET12.acc '#'}  
      else {PenultimateNote getScaleAccidental($)} = {ET12.acc ''} 
      end
   end

   % TODO: this seems wrong (i.e., leading-tone in cantus firmus)
   % force the last note to be leading-tone
   {PenultimateNote getScaleDegree($)} = 7
   
   % TODO: this seems wrong
   % interval to simultaneously sounding note is less than octave
   %{GetInterval PenultimateNote {GetSimNote PenultimateNote}} <: 12
   
   % TODO: find out the exact meaning of this
   {ForAll AllButPenultimateNotes
    proc {$ X}
       {X getScaleAccidental($)} = {HS.score.absoluteToOffsetAccidental 0} end
   }
end

% the only allowed intervals are
% - minor and major second
% - minor and major third
% - fourth
% - fifth
% - ascending major sixth (TODO: check this, my notes are sketchy here)
% - octave
% TODO: what about diminished fourth/fifth?
local
   AllowedIntervals = [~12 ~7 ~5 ~4 ~3 ~2 ~1 1 2 3 4 5 7 9 12]
   
   proc {RestrictIntervalDomain Interval}
     Interval :: {Map AllowedIntervals fun {$ I} I + 12 end}
   end

   proc {PreferSteps Intervals}
      AverageIntervalEncoding = {FD.int 15#30}
   in
      {Pattern.arithmeticMean Intervals AverageIntervalEncoding 10}
   end
in
   proc {RestrictMelodicIntervals Voice}
      Intervals = {Pattern.map2Neighbours {Voice getItems($)} GetInterval}
   in
      {ForAll Intervals RestrictIntervalDomain}
      % TODO this procedure is still unaware of my "shift intervals" approach
      %{PreferSteps Intervals}
   end
end

local
   AllowedIntervals = [~12 0 12]
   proc {IsSuitableInterval CounterpointPitch CantusPitch}
      Interval
   in
      Interval :: {Map AllowedIntervals fun {$ I} I + 12 end}
      Interval =: CounterpointPitch - CantusPitch + 12
   end
in
   proc {StartAndEndWithPerfectConsonance Voice}
      Notes = {Voice getItems($)}
      FirstNote = Notes.1
      LastNote = {List.last Notes}
   in
      %{Browse {Map Notes getPitch($) fun {$ Xs} Xs end}}
      {IsSuitableInterval
       {FirstNote getPitch($)}
       {{GetSimultaneousNote FirstNote} getPitch($)}
      }
      {IsSuitableInterval
       {LastNote getPitch($)}
       {{GetSimultaneousNote LastNote} getPitch($)}
      }
   end
end







%
% Generate output
%

%{GUtils.setRandomGeneratorSeed 0} % always find different solution
{SDistro.exploreOne {GUtils.extendedScriptToScript FirstSpecies
		     unit}
 unit(order:size)}