package funkin.scripted;

import funkin.play.character.BaseCharacter;
#if polymod
import polymod.hscript.HScriptedClass;

@:hscriptClass
#end
class ScriptedStage extends BaseStage #if polymod implements HScriptedClass #end {}
