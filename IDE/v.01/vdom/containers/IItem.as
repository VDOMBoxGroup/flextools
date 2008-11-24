package vdom.containers {
	
import mx.containers.Canvas;

public interface IItem {

function get objectId():String

function get editableAttributes():Array 	
function set editableAttributes(attributesArray:Array):void

function get waitMode():Boolean 	
function set waitMode(mode:Boolean):void

//function get graphicsLayer():Canvas

function get isStatic():Boolean 	
function set isStatic(mode:Boolean):void

function drawHighlight(color:String):void 
	
}
}