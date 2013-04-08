package net.vdombox.helpeditor.model
{
	public class AlertMessages
	{
		public static const MSG_TYPE_ERROR		: String = "Error:";
		public static const MSG_TYPE_WARNING	: String = "Warning:";
		public static const MSG_TYPE_DELETE		: String = "Delete:";
		public static const MSG_TYPE_SQL_ERROR	: String = "SQL error:";
		public static const MSG_TYPE_SAVED_TO	: String = "Saved to:";
		
		public static const MSG_INCORRECT_PRODUCT_VERSION		: String = "You try to load old version of existing product.";
		public static const MSG_ASK_DELETE_PRODUCT				: String = "Delete this Product?";
		public static const MSG_ASK_DELETE_PAGE					: String = "Delete this page?";
		public static const MSG_ASK_DELETE_GROUP				: String = "Delete this group?";
		public static const MSG_ASK_DELETE_TEMPLATE				: String = "Delete this template?";
		public static const MSG_IMPOSSIBLE_OPERATION			: String = "Impossible operation.";
		public static const MSG_XML_CREATING_ERROR				: String = "Error on product xml creating";
		public static const MSG_INCORRECT_XML_FILE_FORMAT		: String = "The file format is incorrect. It should be in xml format.";
		
		public static const MSG_CLIPBOARD_HAS_NO_IMAGES			: String = "No images in clipboard.";
		
		public function AlertMessages()
		{
		}
	}
}