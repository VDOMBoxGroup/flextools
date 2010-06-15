package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.wysiwyg.events.TabEvent;
	
	import spark.components.supportClasses.DisplayLayer;
	import spark.components.supportClasses.OverlayDepth;

	public class Tab extends EventDispatcher
	{
		public function Tab( name : String )
		{
			super();

			_name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		private var _depth : Vector.<Number>;
		private var _objects : Vector.<DisplayObject>;

		private var _name : String;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get name() : String
		{
			return _name;
		}

		public function get numDisplayObjects() : int
		{
			return _objects ? _objects.length : 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getDisplayObjectAt( index : int ) : DisplayObject
		{
			if ( !_objects || index < 0 || index >= _objects.length )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "indexOutOfRange", [ index ] ) );

			return _objects[ index ];
		}

		public function getDisplayObjectDepth( displayObject : DisplayObject ) : Number
		{
			var index : int = _objects.indexOf( displayObject );
			if ( index == -1 )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "objectNotFoundInDisplayLayer", [ displayObject ] ) );

			return _depth[ index ];
		}

		public function addDisplayObject( displayObject : DisplayObject, depth : Number = OverlayDepth.TOP ) : DisplayObject
		{
			// Find index to insert
			var index : int = 0;
			if ( !_depth )
			{
				_depth = new Vector.<Number>;
				_objects = new Vector.<DisplayObject>;
			}
			else
			{
				// Simple linear search
				var count : int = _depth.length;
				for ( ; index < count; index++ )
					if ( depth < _depth[ index ] )
						break;
			}

			// Insert at index:
			_depth.splice( index, 0, depth );
			_objects.splice( index, 0, displayObject );

			// Notify that the object has been added
			dispatchEvent( new TabEvent( TabEvent.OBJECT_ADD, false, false, displayObject, index ) );
			return displayObject;
		}

		public function removeDisplayObject( displayObject : DisplayObject ) : DisplayObject
		{
			var index : int = _objects.indexOf( displayObject );
			if ( index == -1 )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "objectNotFoundInDisplayLayer", [ displayObject ] ) );

			// Notify that the object is to be deleted
			dispatchEvent( new TabEvent( TabEvent.OBJECT_REMOVE, false, false, displayObject, index ) );
			_depth.splice( index, 1 );
			_objects.splice( index, 1 );
			return displayObject;
		}
	}
}