package net.vdombox.ide.modules.wysiwyg.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Container;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
	import spark.components.Application;
	import spark.components.supportClasses.GroupBase;

	public class DisplayUtils
	{

		public static function getObjectsUnderMouse( rootContainer : DisplayObjectContainer, targetClassName : String,
													 filterFunction : Function = null ) : Array
		{
			var app : Application = FlexGlobals.topLevelApplication as Application;

			var allObjectUnderPoint : Array = rootContainer.getObjectsUnderPoint( new Point( rootContainer.mouseX, rootContainer.mouseY ) );

			var stack : Array = [];

			var targetClass : Class = getDefinitionByName( targetClassName ) as Class;

			var dict : Dictionary = new Dictionary();

			for ( var i : int = allObjectUnderPoint.length - 1; i >= 0; i-- )
			{
				var target : DisplayObject = allObjectUnderPoint[ i ];

				while ( target is DisplayObject )
				{
					if ( target is ScrollBar )
						return [];

					if ( target is targetClass && !( target is WorkArea ) )
						break;

					if ( target.hasOwnProperty( "parent" ) )
						target = target.parent;

					else
						target = null;
				}

//			if (target && stack[stack.length - 1] != target) {
				if ( target && !dict[ target ] )
				{
					var check : Boolean = true;

					if ( filterFunction != null )
						check = filterFunction( target );

					if ( check )
					{
						stack.push( target );
						dict[ target ] = true;
					}
				}
			}

			return stack;
		}

		public static function getConvertedPoint( target : DisplayObject, destinationContainer : UIComponent ) : Point
		{
			if ( target == null || target.parent == null || destinationContainer == null )
				return null;

			var pt : Point = new Point( target.x, target.y );
			var tc : UIComponent = target.parent as UIComponent;
			var dc : UIComponent = destinationContainer.parent as UIComponent;

			pt = tc.contentToGlobal( pt );
			pt = dc.globalToContent( pt );

			return pt;
		}
	}
}