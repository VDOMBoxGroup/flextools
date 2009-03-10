package vdom.utils
{

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Application;
	import mx.core.Container;

	public class DisplayUtils
	{

		public static function getObjectsUnderMouse( rootContainer : DisplayObjectContainer,
													 targetClassName : String, filterFunction : Function = null ) : Array
		{
			var app : Application = Application.application as Application;

			var allObjectUnderPoint : Array = app.stage.getObjectsUnderPoint( new Point( app.stage.mouseX,
																						 app.stage.mouseY ) );

			var stack : Array = [];

			var targetClass : Class = getDefinitionByName( targetClassName )as Class;

			var dict : Dictionary = new Dictionary();

			for ( var i : int = allObjectUnderPoint.length - 1; i >= 0; i-- )
			{
				var target : DisplayObject = allObjectUnderPoint[ i ];

				while ( target is DisplayObject )
				{
					if ( target is ScrollBar )
						return [];

					if ( target is targetClass )
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

		public static function getConvertedPoint( target : DisplayObject, destinationContainer : Container ) : Point
		{
			if ( target == null || target.parent == null || destinationContainer == null )
				return null;

			var pt : Point = new Point( target.x, target.y );
			var tc : Container = Container( target.parent );
			var dc : Container = Container( destinationContainer.parent );

			pt = tc.contentToGlobal( pt );
			pt = destinationContainer.globalToContent( pt );

			return pt;
		}
	}
}