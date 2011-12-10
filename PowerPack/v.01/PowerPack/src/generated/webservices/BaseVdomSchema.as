package generated.webservices
{

import mx.rpc.xml.Schema;

public class BaseVdomSchema
{
	public var schemas : Array = new Array();
	public var targetNamespaces : Array = new Array();

	public function BaseVdomSchema() : void
	{
		var xsdXML0 : XML = <s:schema xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.xmlsoap.org/wsdl/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:s0="http://services.vdom.net/VDOMServices" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://services.vdom.net/VDOMServices">
			<s:element name="get_echo">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_echoResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_guid">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_guidResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="delete_object">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="delete_objectResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="update_object">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="data" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="update_objectResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_delete">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_deleteResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="search">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="pattern" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="searchResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="keep_alive">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="keep_aliveResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="close_session">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="close_sessionResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="open_session">
				<s:complexType>
					<s:sequence>
						<s:element name="name" type="s:string"/>
						<s:element name="pwd_md5" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="open_sessionResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_type">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="typeid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_typeResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_server_actions">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="actions" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_server_actionsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="send_event">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="evdata" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="send_eventResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_objects">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="parentid" type="s:string"/>
						<s:element name="objects" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_objectsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_info">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="attr" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_infoResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_applications">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_applicationsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="export_application">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="export_applicationResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="execute_sql">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="dbid" type="s:string"/>
						<s:element name="sql" type="s:string"/>
						<s:element name="script" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="execute_sqlResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_application">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="attr" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_applicationResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="submit_object_script_presentation">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="pres" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="submit_object_script_presentationResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_create">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="parentid" type="s:string"/>
						<s:element name="name" type="s:string"/>
						<s:element name="data" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_createResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="remote_method_call">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="func_name" type="s:string"/>
						<s:element name="xml_param" type="s:string"/>
						<s:element name="session_id" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="remote_method_callResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_structure">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_structureResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_thumbnail">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="resid" type="s:string"/>
						<s:element name="width" type="s:string"/>
						<s:element name="height" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_thumbnailResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_language_data">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_language_dataResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_structure">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="struct" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_structureResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_one_object">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_one_objectResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_name">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="name" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_nameResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_create_page">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="sourceid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_create_pageResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_types">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_typesResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_object">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="parentid" type="s:string"/>
						<s:element name="typeid" type="s:string"/>
						<s:element name="name" type="s:string"/>
						<s:element name="attr" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="create_objectResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="render_wysiwyg">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="parentid" type="s:string"/>
						<s:element name="dynamic" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="render_wysiwygResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_attributes">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="attr" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_attributesResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_script">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="script" type="s:string"/>
						<s:element name="lang" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_scriptResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_info">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_infoResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_script">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="lang" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_scriptResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_child_objects_tree">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_child_objects_treeResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="modify_resource">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="resid" type="s:string"/>
						<s:element name="attrname" type="s:string"/>
						<s:element name="operation" type="s:string"/>
						<s:element name="attr" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="modify_resourceResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_child_objects">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_child_objectsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_resource">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="ownerid" type="s:string"/>
						<s:element name="resid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_resourceResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_code_interface_data">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_code_interface_dataResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_events">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_application_eventsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="about">
				<s:complexType>
					<s:sequence/>
				</s:complexType>
			</s:element>
			<s:element name="aboutResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_resource">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="restype" type="s:string"/>
						<s:element name="resname" type="s:string"/>
						<s:element name="resdata" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_resourceResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_events">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="events" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_application_eventsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_resources">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="ownerid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="list_resourcesResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_all_types">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_all_typesResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_attribute">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="attr" type="s:string"/>
						<s:element name="value" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="set_attributeResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_update">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
						<s:element name="data" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="whole_updateResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_object_script_presentation">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
						<s:element name="objid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_object_script_presentationResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="install_application">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="vhname" type="s:string"/>
						<s:element name="appxml" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="install_applicationResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_top_objects">
				<s:complexType>
					<s:sequence>
						<s:element name="sid" type="s:string"/>
						<s:element name="skey" type="s:string"/>
						<s:element name="appid" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
			<s:element name="get_top_objectsResponse">
				<s:complexType>
					<s:sequence>
						<s:element name="Result" type="s:string"/>
					</s:sequence>
				</s:complexType>
			</s:element>
		</s:schema>
				;
		var xsdSchema0 : Schema = new Schema( xsdXML0 );
		schemas.push( xsdSchema0 );
		targetNamespaces.push( new Namespace( '', 'http://services.vdom.net/VDOMServices' ) );
	}
}
}