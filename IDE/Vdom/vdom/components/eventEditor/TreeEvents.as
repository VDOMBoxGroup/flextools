package vdom.components.eventEditor
{
	import vdom.managers.DataManager;

	public class TreeEvents extends DragTree
	{
		private var dataManager:DataManager ;
		public function TreeEvents()
		{
			super();
			dataManager = DataManager.getInstance();
			
		}
		
		/* <Event Name='onmousedown'/>
                <Event Name='onmouseup'/>
                <Event Name='onmouseover'/>
                <Event Name='onmousemove'/>
                <Event Name='onmouseout'/>
                <Event Name='ondrag'/>
                <Event Name='ondragend'/>
                <Event Name='onclick'/>
                <Event Name='onselectstart'/>
                <Event Name='ondblclick'/>
                <Event Name='Crtl+C'/>
                <Event Name='Crtl+V'/>
*/
		override public function set dataProvider(value:Object):void
		{
			/*
			var temp:XML = 
			<event>
			<Object label="header_image" ID="d3fe27c0-819d-4538-ab74-9050257f1fc0" Type="0d36c35d-9508-440f-bfec-668f3db8cfeb" resourceID="93ef9321-8862-4d84-9cf4-a8a1a711bfa9">
				
			</Object>
			<Object label="school_name_copy" ID="06e2904c-6989-46cf-9c89-c6be3cbd164a" Type="5c1b98df-8609-4660-83b2-44ec7b2e7611" resourceID="b83b4547-2ef2-4cb2-8e51-23ddf90282a8"/>
			<Object label="main_menu_copy" ID="7be8f112-0069-4940-ac39-2a26d9c81405" Type="5c1b98df-8609-4660-83b2-44ec7b2e7611" resourceID="b83b4547-2ef2-4cb2-8e51-23ddf90282a8"/>
			<Object label="back_image_with_menu_background_copy" ID="1c0da28b-cc20-4459-9a71-f4fed6f2a961" Type="5c1b98df-8609-4660-83b2-44ec7b2e7611" resourceID="b83b4547-2ef2-4cb2-8e51-23ddf90282a8"/>
			<Object label="back_image_sample" ID="b76aa2a7-33b9-4a38-9a81-cfb910f61ca0" Type="0d36c35d-9508-440f-bfec-668f3db8cfeb" resourceID="93ef9321-8862-4d84-9cf4-a8a1a711bfa9"/>
			<Object label="back_image_with_stain" ID="de79cc9c-a40b-4325-8025-951f33a74191" Type="0d36c35d-9508-440f-bfec-668f3db8cfeb" resourceID="93ef9321-8862-4d84-9cf4-a8a1a711bfa9"/>
			<Object label="admin_menu" ID="f4a7c35e-4450-47be-a48b-a57d55fe1515" Type="03741d38-c9f3-4526-acb9-71c7aa00b3b2" resourceID="bf136799-e543-4a60-9921-75b473cef1e4"/>
			<Object label="login_form" ID="4e3f096d-f18d-44ae-9d5b-7a13ff40963d" Type="34f6ee59-9c50-4503-97c1-86c4e86bd1b7" resourceID="4be3ae79-9e07-4060-a136-7a5ae4ecab20"/>
			<Object label="auth_text" ID="5bd493d9-7d6b-47b1-af6f-e7028e9d3095" Type="73a54f2e-4001-4676-93a0-804048a57081" resourceID="114eb656-776b-4ec4-912b-d7e0c51cd906"/>
			<Object label="auth_name_text" ID="8f552894-fb3f-4076-b859-0bde5e656db4" Type="73a54f2e-4001-4676-93a0-804048a57081" resourceID="114eb656-776b-4ec4-912b-d7e0c51cd906"/>
			<Object label="logout_form" ID="e214c4b3-e8bd-489d-982c-12e92c4e623d" Type="34f6ee59-9c50-4503-97c1-86c4e86bd1b7" resourceID="4be3ae79-9e07-4060-a136-7a5ae4ecab20"/>
			</event>; 
		*/	
		  var dataXML:XML = <root/>;	
		  for each(var child:XML in value)
		  {
		  		dataXML.appendChild(getChilds(child))
		  }
			super.dataProvider = dataXML;
		}
		
		private function getChilds(inXML:XML):XML
		{
			var type:XML = dataManager.getTypeByTypeId(inXML.@Type);
			var tempXML:XML;
			var outXML:XML = new XML(inXML.toXMLString())
			
			for each(var child:XML in type.E2vdom.Events.Userinterfaceevents.children() )
			{
			 	tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@parentID = inXML.@ID;
			//	tempXML.@parentType = inXML.@Type;
				
				outXML.appendChild(tempXML);
			} 
			
			for each(child in type.E2vdom.Events.Objectevents.children() )
			{
				tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@parentID = inXML.@ID;
			//	tempXML.@parentType = inXML.@Type;
			
				outXML.appendChild(tempXML);
			} 
		/*	
			<Object label="header_image" ID="d3fe27c0-819d-4538-ab74-9050257f1fc0" Type="0d36c35d-9508-440f-bfec-668f3db8cfeb" resourceID="93ef9321-8862-4d84-9cf4-a8a1a711bfa9">
				<Event label="onmousedown" parentID="" parentType=""/>
				<Event label="onmousedown2"/>
			</Object>		*/	
			
			return outXML;
		}
	}
}