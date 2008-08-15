package vdom.controls {
	
import vdom.containers.IItem;	
	
public interface IToolBar {

function init(item:IItem):void

function close():void

function get selfChanged():Boolean;

}
}