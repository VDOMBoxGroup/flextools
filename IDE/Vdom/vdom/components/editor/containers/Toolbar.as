package vdom.components.editor.containers
{
import mx.containers.Canvas;
import mx.controls.Button;
import vdom.components.editor.containers.toolbarClasses.TextTools;
import vdom.components.editor.containers.toolbarClasses.RichTextTools;
import vdom.components.editor.containers.toolbarClasses.ImageTools;

public class Toolbar extends Canvas
{	
	private var _type:uint;
	private var _interfaceTypes:Array;
	
	public function Toolbar()
	{
		super();
		_type = 0;
		_interfaceTypes = new Array();
		_interfaceTypes[2] = new TextTools();
		_interfaceTypes[3] = new RichTextTools();
		_interfaceTypes[4] = new ImageTools();
		
	}
	
	override protected function measure():void
    {
        super.measure();
        measuredMinHeight = 0;
    }
    
    public function set type(elementAttributes:Object):void {
    	if(elementAttributes)
    		_type = parseInt(elementAttributes.Type.Information.InterfaceType.toString());
    	else
    		_type = 0;
    		
    	invalidateDisplayList();
    	
    }
    
    override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		removeAllChildren();
		
		if(_interfaceTypes[_type]) {
        	addChild(_interfaceTypes[_type]);
        }
	}
    
    /* override protected function createChildren():void
    {
        super.createChildren();
        var zzz:ImageTools = new ImageTools()
        addChild(zzz);
        if(_interfaceTypes[_type]) {
        	addChild(_interfaceTypes[_type]);
        }
    } */
}
}
