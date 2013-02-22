package net.vdombox.components.xmldialogeditor.model.vo.components.base
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;

	public class ComponentText extends ComponentAddition
	{
		protected var _text : AttributeStringVO;
		protected var _placeHolder : AttributeStringVO;
		protected var _readonly : Boolean;
		protected var _width : AttributeIntVO;
		
		 
		public function ComponentText(value:XML)
		{
			super(value);
			
			if ( value && value.@readonly[0] && value.@readonly == "true" )
				readonly = true;
			else
				readonly = false;
			
			if ( value && value.@width[0] )
				width = new AttributeIntVO("width", value.@width );
			else
				width = new AttributeIntVO("width", 100);
			
			
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var propertyList : XMLList = value.Properties[0].children();
				
				for each ( var property : XML in propertyList )
				{
					var name : String = property.@name[0];
					
					switch(name)
					{	
						case "text":
						{
							text =  new AttributeStringVO( 'text', property.toString() );
							break;
						}
							
						case "placeHolder":
						{
							placeHolder =  new AttributeStringVO( 'placeHolder', property.toString() );
							break;
						}
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if ( !text )
				text = new AttributeStringVO( 'text', "text" );
			
			if ( !placeHolder )
				placeHolder = new AttributeStringVO( 'placeHolder', "" );
		}

		public function get placeHolder():AttributeStringVO
		{
			return _placeHolder;
		}

		public function set placeHolder(value:AttributeStringVO):void
		{
			_placeHolder = value;
		}

		public function get width():AttributeIntVO
		{
			return _width;
		}

		public function set width(value:AttributeIntVO):void
		{
			_width = value;
		}

		[Bindable]
		public function get text():AttributeStringVO
		{
			return _text;
		}

		public function set text(value:AttributeStringVO):void
		{
			_text = value;
		}
		
		public function get readonly():Boolean
		{
			return _readonly;
		}
		
		public function set readonly(value:Boolean):void
		{
			_readonly = value;
		}
		
		public override function get attributes() : ArrayCollection
		{	
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( width );
			_attributes.addItem( text );
			_attributes.addItem( readonly );
			_attributes.addItem( placeHolder );
			
			return _attributes;
		}

	}
}