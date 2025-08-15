package funkin.scripted;

import funkin.play.character.BaseCharacter;
#if polymod
import polymod.hscript.HScriptedClass;

@:hscriptClass
#end
class ScriptedBaseCharacter extends BaseCharacter #if polymod implements HScriptedClass #end {}
