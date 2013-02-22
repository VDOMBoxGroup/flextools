package net.vdombox.components.xmldialogeditor.model.vo.components.base
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;

	public class ComponentAddition extends ComponentBase
	{
		protected var _id : AttributeStringVO;
		protected var _visible : AttributeBoolVO;
		protected var _enabled : AttributeBoolVO;
		
		protected var _className : AttributeStringVO;
		protected var _toolTip : AttributeStringVO;
		
		public function ComponentAddition(value:XML)
		{
			super(value);
			
			if ( value && value.@id[0] )
				id = new AttributeStringVO( 'id', value.@['id'] );
			else
				id = new AttributeStringVO ( 'id', "" );
			
			if ( value && value.@visible[0] && value.@visible == "false" )
				visible = new AttributeBoolVO( "visible", false );
			else
				visible = new AttributeBoolVO( "visible", true );
			
			if ( value && value.@enabled[0] && value.@disabled == "false" )
				enabled = new AttributeBoolVO( "enabled", false );
			else
				enabled = new AttributeBoolVO( "enabled", true );
			
			if ( value && value.@['class'][0] )
				className = new AttributeStringVO( 'class', value.@['class'] );
			else
				className = new AttributeStringVO( 'class', "" );
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var propertyList : XMLList = value.Properties[0].children();
				
				for each ( var property : XML in propertyList )
				{
					var name : String = property.@name[0];
					
					switch(name)
					{
						case "toolTip":
						{
							toolTip = new AttributeStringVO( 'toolTip', property.toString() );
							break;
						}
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if ( !toolTip )
				toolTip = new AttributeStringVO( 'toolTip', "" );
		}

		public function get toolTip():AttributeStringVO
		{
			return _toolTip;
		}

		public function set toolTip(value:AttributeStringVO):void
		{
			_toolTip = value;
		}

		public function get id():AttributeStringVO
		{
			return _id;
		}

		public function set id(value:AttributeStringVO):void
		{
			_id = value;
		}

		public function get visible():AttributeBoolVO
		{
			return _visible;
		}

		public function set visible(value:AttributeBoolVO):void
		{
			_visible = value;
		}

		public function get enabled():AttributeBoolVO
		{
			return _enabled;
		}

		public function set enabled(value:AttributeBoolVO):void
		{
			_enabled = value;
		}

		public function get className():AttributeStringVO
		{
			return _className;
		}
		
		public function set className(value:AttributeStringVO):void
		{
			_className = value;
		}
	}
}