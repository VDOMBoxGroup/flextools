package net.vdombox.components.tabNavigatorClasses
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import mx.core.IVisualElement;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.events.TabEvent;
	
	import spark.components.Group;

	public class Tab extends EventDispatcher
	{
		public function Tab()
		{
			super();
		}

		public var label : String = "Untitled";
		public var id : String;

		private var _objects : Vector.<IVisualElement>;

		public function get numElements() : int
		{
			return _objects ? _objects.length : 0;
		}

		public function getElementAt( index : int ) : IVisualElement
		{
			if ( !_objects || index < 0 || index >= _objects.length )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "indexOutOfRange", [ index ] ) );

			return _objects[ index ];
		}

		public function getElementIndex( element : IVisualElement ) : int
		{
			var index : int = _objects.indexOf( element );

			if ( index == -1 )
				throw ArgumentError( ResourceManager.getInstance().getString( "components", "elementNotFoundInGroup", [ element ] ) );
			else
				return index;
		}

		public function addElement( element : IVisualElement ) : IVisualElement
		{
			var index : int;

			if ( !_objects )
				_objects = new Vector.<IVisualElement>;

			index = _objects.length;

			return addElementAt( element, index );
		}

		public function addElementAt( element : IVisualElement, index : uint ) : IVisualElement
		{
			if ( !_objects )
				_objects = new Vector.<IVisualElement>;

			var oldIndex : int = _objects.indexOf( element );

			if ( oldIndex != -1 )
			{
				checkForRangeError( index, false );
				_objects.splice( oldIndex, 1 );
			}
			else
			{
				checkForRangeError( index, true );
			}

			_objects.splice( index, 0, element );

			dispatchEvent( new TabEvent( TabEvent.ELEMENT_ADD, false, false, element, index ) );

			return element;
		}

		public function removeElement( element : IVisualElement ) : IVisualElement
		{
			var index : int = _objects.indexOf( element );
			
			if ( index == -1 )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "objectNotFoundInDisplayLayer", [ element ] ) );

			// Notify that the object is to be deleted
			dispatchEvent( new TabEvent( TabEvent.ELEMENT_REMOVE,
				false /*bubbles*/,
				false /*cancelable*/,
				element,
				index ) );
			
			_objects.splice( index, 1 );
			
			return element;
		}

		private function checkForRangeError( index : int, addingElement : Boolean = false ) : void
		{
			var maxIndex : int = _objects ? _objects.length : 0;

			if ( addingElement )
				maxIndex++;

			if ( index < 0 || index > maxIndex )
				throw new RangeError( ResourceManager.getInstance().getString( "components", "indexOutOfRange", [ index ] ) );
		}
	}
}