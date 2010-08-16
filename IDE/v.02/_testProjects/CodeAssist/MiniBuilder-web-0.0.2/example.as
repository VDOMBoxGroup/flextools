package
{
	import org.aswing.colorchooser.JColorMixer;
	import flash.utils.setTimeout;

	import flash.display.*;
	import flash.events.*;
	import org.aswing.*;

	public class Main extends Sprite
	{
	    
	    private var pane:Sprite;
	    
	    public function Main()
	    {
	        if(stage)
	            init();
	        else
	            addEventListener('addedToStage', init);
	    }
	    
	    private function init(e:Event=null):void
	    {
	        AsWingManager.initAsStandard(this);
	        pane = new Sprite();
	        pane.x = 200;
	        pane.y = 200;
	        addChild(pane);
	        
	        var jf:JFrame = new JFrame(pane, "Hello MiniBuilder");
	        jf.setComBoundsXYWH(-100, -100, 500, 300);
	        var cp:Container = jf.getContentPane();
	        cp.setLayout(new FlowWrapLayout);
	        cp.append(new JColorChooser);
	        cp.append(new JLoadPane('http://www.victordramba.com/wp-content/uploads/2008/03/me.thumbnail.png'));
	        jf.show();
	        
	        addEventListener(Event.ENTER_FRAME, __enterFrame);
	    }
	    
	    private function __enterFrame(e:Event):void
	    {
	        pane.rotationY = -20;
	        removeEventListener(Event.ENTER_FRAME, __enterFrame);
	    }
	        
	}
}