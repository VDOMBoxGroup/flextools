package
{
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	

	public class Utils
	{
		public static const KB : Number = 1024;
		
		public static const FLOAT_DELIMETR : String = ".";
		
		static private var entityMap		: Object = { '&nbsp;':'&#160;', '&iexcl;':'&#161;', '&cent;':'&#162;', '&pound;':'&#163;', '&curren;':'&#164;', '&yen;':'&#165;', '&brvbar;':'&#166;', '&sect;':'&#167;', '&uml;':'&#168;', '&copy;':'&#169;', '&ordf;':'&#170;', '&laquo;':'&#171;', '&not;':'&#172;', '&shy;':'&#173;', '&reg;':'&#174;', '&macr;':'&#175;', '&deg;':'&#176;', '&plusmn;':'&#177;', '&sup2;':'&#178;', '&sup3;':'&#179;', '&acute;':'&#180;', '&micro;':'&#181;', '&para;':'&#182;', '&middot;':'&#183;', '&cedil;':'&#184;', '&sup1;':'&#185;', '&ordm;':'&#186;', '&raquo;':'&#187;', '&frac14;':'&#188;', '&frac12;':'&#189;', '&frac34;':'&#190;', '&iquest;':'&#191;', '&Agrave;':'&#192;', '&Aacute;':'&#193;', '&Acirc;':'&#194;', '&Atilde;':'&#195;', '&Auml;':'&#196;', '&Aring;':'&#197;', '&AElig;':'&#198;', '&Ccedil;':'&#199;', '&Egrave;':'&#200;', '&Eacute;':'&#201;', '&Ecirc;':'&#202;', '&Euml;':'&#203;', '&Igrave;':'&#204;', '&Iacute;':'&#205;', '&Icirc;':'&#206;', '&Iuml;':'&#207;', '&ETH;':'&#208;', '&Ntilde;':'&#209;', '&Ograve;':'&#210;', '&Oacute;':'&#211;', '&Ocirc;':'&#212;', '&Otilde;':'&#213;', '&Ouml;':'&#214;', '&times;':'&#215;', '&Oslash;':'&#216;', '&Ugrave;':'&#217;', '&Uacute;':'&#218;', '&Ucirc;':'&#219;', '&Uuml;':'&#220;', '&Yacute;':'&#221;', '&THORN;':'&#222;', '&szlig;':'&#223;', '&agrave;':'&#224;', '&aacute;':'&#225;', '&acirc;':'&#226;', '&atilde;':'&#227;', '&auml;':'&#228;', '&aring;':'&#229;', '&aelig;':'&#230;', '&ccedil;':'&#231;', '&egrave;':'&#232;', '&eacute;':'&#233;', '&ecirc;':'&#234;', '&euml;':'&#235;', '&igrave;':'&#236;', '&iacute;':'&#237;', '&icirc;':'&#238;', '&iuml;':'&#239;', '&eth;':'&#240;', '&ntilde;':'&#241;', '&ograve;':'&#242;', '&oacute;':'&#243;', '&ocirc;':'&#244;', '&otilde;':'&#245;', '&ouml;':'&#246;', '&divide;':'&#247;', '&oslash;':'&#248;', '&ugrave;':'&#249;', '&uacute;':'&#250;', '&ucirc;':'&#251;', '&uuml;':'&#252;', '&yacute;':'&#253;', '&thorn;':'&#254;', '&yuml;':'&#255;', '&fnof;':'&#402;', '&Alpha;':'&#913;', '&Beta;':'&#914;', '&Gamma;':'&#915;', '&Delta;':'&#916;', '&Epsilon;':'&#917;', '&Zeta;':'&#918;', '&Eta;':'&#919;', '&Theta;':'&#920;', '&Iota;':'&#921;', '&Kappa;':'&#922;', '&Lambda;':'&#923;', '&Mu;':'&#924;', '&Nu;':'&#925;', '&Xi;':'&#926;', '&Omicron;':'&#927;', '&Pi;':'&#928;', '&Rho;':'&#929;', '&Sigma;':'&#931;', '&Tau;':'&#932;', '&Upsilon;':'&#933;', '&Phi;':'&#934;', '&Chi;':'&#935;', '&Psi;':'&#936;', '&Omega;':'&#937;', '&alpha;':'&#945;', '&beta;':'&#946;', '&gamma;':'&#947;', '&delta;':'&#948;', '&epsilon;':'&#949;', '&zeta;':'&#950;', '&eta;':'&#951;', '&theta;':'&#952;', '&iota;':'&#953;', '&kappa;':'&#954;', '&lambda;':'&#955;', '&mu;':'&#956;', '&nu;':'&#957;', '&xi;':'&#958;', '&omicron;':'&#959;', '&pi;':'&#960;', '&rho;':'&#961;', '&sigmaf;':'&#962;', '&sigma;':'&#963;', '&tau;':'&#964;', '&upsilon;':'&#965;', '&phi;':'&#966;', '&chi;':'&#967;', '&psi;':'&#968;', '&omega;':'&#969;', '&thetasym;':'&#977;', '&upsih;':'&#978;', '&piv;':'&#982;', '&bull;':'&#8226;', '&hellip;':'&#8230;', '&prime;':'&#8242;', '&Prime;':'&#8243;', '&oline;':'&#8254;', '&frasl;':'&#8260;', '&weierp;':'&#8472;', '&image;':'&#8465;', '&real;':'&#8476;', '&trade;':'&#8482;', '&alefsym;':'&#8501;', '&larr;':'&#8592;', '&uarr;':'&#8593;', '&rarr;':'&#8594;', '&darr;':'&#8595;', '&harr;':'&#8596;', '&crarr;':'&#8629;', '&lArr;':'&#8656;', '&uArr;':'&#8657;', '&rArr;':'&#8658;', '&dArr;':'&#8659;', '&hArr;':'&#8660;', '&forall;':'&#8704;', '&part;':'&#8706;', '&exist;':'&#8707;', '&empty;':'&#8709;', '&nabla;':'&#8711;', '&isin;':'&#8712;', '&notin;':'&#8713;', '&ni;':'&#8715;', '&prod;':'&#8719;', '&sum;':'&#8721;', '&minus;':'&#8722;', '&lowast;':'&#8727;', '&radic;':'&#8730;', '&prop;':'&#8733;', '&infin;':'&#8734;', '&ang;':'&#8736;', '&and;':'&#8743;', '&or;':'&#8744;', '&cap;':'&#8745;', '&cup;':'&#8746;', '&int;':'&#8747;', '&there4;':'&#8756;', '&sim;':'&#8764;', '&cong;':'&#8773;', '&asymp;':'&#8776;', '&ne;':'&#8800;', '&equiv;':'&#8801;', '&le;':'&#8804;', '&ge;':'&#8805;', '&sub;':'&#8834;', '&sup;':'&#8835;', '&nsub;':'&#8836;', '&sube;':'&#8838;', '&supe;':'&#8839;', '&oplus;':'&#8853;', '&otimes;':'&#8855;', '&perp;':'&#8869;', '&sdot;':'&#8901;', '&lceil;':'&#8968;', '&rceil;':'&#8969;', '&lfloor;':'&#8970;', '&rfloor;':'&#8971;', '&lang;':'&#9001;', '&rang;':'&#9002;', '&loz;':'&#9674;', '&spades;':'&#9824;', '&clubs;':'&#9827;', '&hearts;':'&#9829;', '&diams;':'&#9830;', '"':'&#34;', '&':'&#38;', '<':'&#60;', '>':'&#62;', '&OElig;':'&#338;', '&oelig;':'&#339;', '&Scaron;':'&#352;', '&scaron;':'&#353;', '&Yuml;':'&#376;', '&circ;':'&#710;', '&tilde;':'&#732;', '&ensp;':'&#8194;', '&emsp;':'&#8195;', '&thinsp;':'&#8201;', '&zwnj;':'&#8204;', '&zwj;':'&#8205;', '&lrm;':'&#8206;', '&rlm;':'&#8207;', '&ndash;':'&#8211;', '&mdash;':'&#8212;', '&lsquo;':'&#8216;', '&rsquo;':'&#8217;', '&sbquo;':'&#8218;', '&ldquo;':'&#8220;', '&rdquo;':'&#8221;', '&bdquo;':'&#8222;', '&dagger;':'&#8224;', '&Dagger;':'&#8225;', '&permil;':'&#8240;', '&lsaquo;':'&#8249;', '&rsaquo;':'&#8250;', '&euro;':'&#8364;' };
		static private var entityMapWithAMP	: Object = { '&amp;nbsp;':'&#160;', '&amp;iexcl;':'&#161;', '&amp;cent;':'&#162;', '&amp;pound;':'&#163;', '&amp;curren;':'&#164;', '&amp;yen;':'&#165;', '&amp;brvbar;':'&#166;', '&amp;sect;':'&#167;', '&amp;uml;':'&#168;', '&amp;copy;':'&#169;', '&amp;ordf;':'&#170;', '&amp;laquo;':'&#171;', '&amp;not;':'&#172;', '&amp;shy;':'&#173;', '&amp;reg;':'&#174;', '&amp;macr;':'&#175;', '&amp;deg;':'&#176;', '&amp;plusmn;':'&#177;', '&amp;sup2;':'&#178;', '&amp;sup3;':'&#179;', '&amp;acute;':'&#180;', '&amp;micro;':'&#181;', '&amp;para;':'&#182;', '&amp;middot;':'&#183;', '&amp;cedil;':'&#184;', '&amp;sup1;':'&#185;', '&amp;ordm;':'&#186;', '&amp;raquo;':'&#187;', '&amp;frac14;':'&#188;', '&amp;frac12;':'&#189;', '&amp;frac34;':'&#190;', '&amp;iquest;':'&#191;', '&amp;Agrave;':'&#192;', '&amp;Aacute;':'&#193;', '&amp;Acirc;':'&#194;', '&amp;Atilde;':'&#195;', '&amp;Auml;':'&#196;', '&amp;Aring;':'&#197;', '&amp;AElig;':'&#198;', '&amp;Ccedil;':'&#199;', '&amp;Egrave;':'&#200;', '&amp;Eacute;':'&#201;', '&amp;Ecirc;':'&#202;', '&amp;Euml;':'&#203;', '&amp;Igrave;':'&#204;', '&amp;Iacute;':'&#205;', '&amp;Icirc;':'&#206;', '&amp;Iuml;':'&#207;', '&amp;ETH;':'&#208;', '&amp;Ntilde;':'&#209;', '&amp;Ograve;':'&#210;', '&amp;Oacute;':'&#211;', '&amp;Ocirc;':'&#212;', '&amp;Otilde;':'&#213;', '&amp;Ouml;':'&#214;', '&amp;times;':'&#215;', '&amp;Oslash;':'&#216;', '&amp;Ugrave;':'&#217;', '&amp;Uacute;':'&#218;', '&amp;Ucirc;':'&#219;', '&amp;Uuml;':'&#220;', '&amp;Yacute;':'&#221;', '&amp;THORN;':'&#222;', '&amp;szlig;':'&#223;', '&amp;agrave;':'&#224;', '&amp;aacute;':'&#225;', '&amp;acirc;':'&#226;', '&amp;atilde;':'&#227;', '&amp;auml;':'&#228;', '&amp;aring;':'&#229;', '&amp;aelig;':'&#230;', '&amp;ccedil;':'&#231;', '&amp;egrave;':'&#232;', '&amp;eacute;':'&#233;', '&amp;ecirc;':'&#234;', '&amp;euml;':'&#235;', '&amp;igrave;':'&#236;', '&amp;iacute;':'&#237;', '&amp;icirc;':'&#238;', '&amp;iuml;':'&#239;', '&amp;eth;':'&#240;', '&amp;ntilde;':'&#241;', '&amp;ograve;':'&#242;', '&amp;oacute;':'&#243;', '&amp;ocirc;':'&#244;', '&amp;otilde;':'&#245;', '&amp;ouml;':'&#246;', '&amp;divide;':'&#247;', '&amp;oslash;':'&#248;', '&amp;ugrave;':'&#249;', '&amp;uacute;':'&#250;', '&amp;ucirc;':'&#251;', '&amp;uuml;':'&#252;', '&amp;yacute;':'&#253;', '&amp;thorn;':'&#254;', '&amp;yuml;':'&#255;', '&amp;fnof;':'&#402;', '&amp;Alpha;':'&#913;', '&amp;Beta;':'&#914;', '&amp;Gamma;':'&#915;', '&amp;Delta;':'&#916;', '&amp;Epsilon;':'&#917;', '&amp;Zeta;':'&#918;', '&amp;Eta;':'&#919;', '&amp;Theta;':'&#920;', '&amp;Iota;':'&#921;', '&amp;Kappa;':'&#922;', '&amp;Lambda;':'&#923;', '&amp;Mu;':'&#924;', '&amp;Nu;':'&#925;', '&amp;Xi;':'&#926;', '&amp;Omicron;':'&#927;', '&amp;Pi;':'&#928;', '&amp;Rho;':'&#929;', '&amp;Sigma;':'&#931;', '&amp;Tau;':'&#932;', '&amp;Upsilon;':'&#933;', '&amp;Phi;':'&#934;', '&amp;Chi;':'&#935;', '&amp;Psi;':'&#936;', '&amp;Omega;':'&#937;', '&amp;alpha;':'&#945;', '&amp;beta;':'&#946;', '&amp;gamma;':'&#947;', '&amp;delta;':'&#948;', '&amp;epsilon;':'&#949;', '&amp;zeta;':'&#950;', '&amp;eta;':'&#951;', '&amp;theta;':'&#952;', '&amp;iota;':'&#953;', '&amp;kappa;':'&#954;', '&amp;lambda;':'&#955;', '&amp;mu;':'&#956;', '&amp;nu;':'&#957;', '&amp;xi;':'&#958;', '&amp;omicron;':'&#959;', '&amp;pi;':'&#960;', '&amp;rho;':'&#961;', '&amp;sigmaf;':'&#962;', '&amp;sigma;':'&#963;', '&amp;tau;':'&#964;', '&amp;upsilon;':'&#965;', '&amp;phi;':'&#966;', '&amp;chi;':'&#967;', '&amp;psi;':'&#968;', '&amp;omega;':'&#969;', '&amp;thetasym;':'&#977;', '&amp;upsih;':'&#978;', '&amp;piv;':'&#982;', '&amp;bull;':'&#8226;', '&amp;hellip;':'&#8230;', '&amp;prime;':'&#8242;', '&amp;Prime;':'&#8243;', '&amp;oline;':'&#8254;', '&amp;frasl;':'&#8260;', '&amp;weierp;':'&#8472;', '&amp;image;':'&#8465;', '&amp;real;':'&#8476;', '&amp;trade;':'&#8482;', '&amp;alefsym;':'&#8501;', '&amp;larr;':'&#8592;', '&amp;uarr;':'&#8593;', '&amp;rarr;':'&#8594;', '&amp;darr;':'&#8595;', '&amp;harr;':'&#8596;', '&amp;crarr;':'&#8629;', '&amp;lArr;':'&#8656;', '&amp;uArr;':'&#8657;', '&amp;rArr;':'&#8658;', '&amp;dArr;':'&#8659;', '&amp;hArr;':'&#8660;', '&amp;forall;':'&#8704;', '&amp;part;':'&#8706;', '&amp;exist;':'&#8707;', '&amp;empty;':'&#8709;', '&amp;nabla;':'&#8711;', '&amp;isin;':'&#8712;', '&amp;notin;':'&#8713;', '&amp;ni;':'&#8715;', '&amp;prod;':'&#8719;', '&amp;sum;':'&#8721;', '&amp;minus;':'&#8722;', '&amp;lowast;':'&#8727;', '&amp;radic;':'&#8730;', '&amp;prop;':'&#8733;', '&amp;infin;':'&#8734;', '&amp;ang;':'&#8736;', '&amp;and;':'&#8743;', '&amp;or;':'&#8744;', '&amp;cap;':'&#8745;', '&amp;cup;':'&#8746;', '&amp;int;':'&#8747;', '&amp;there4;':'&#8756;', '&amp;sim;':'&#8764;', '&amp;cong;':'&#8773;', '&amp;asymp;':'&#8776;', '&amp;ne;':'&#8800;', '&amp;equiv;':'&#8801;', '&amp;le;':'&#8804;', '&amp;ge;':'&#8805;', '&amp;sub;':'&#8834;', '&amp;sup;':'&#8835;', '&amp;nsub;':'&#8836;', '&amp;sube;':'&#8838;', '&amp;supe;':'&#8839;', '&amp;oplus;':'&#8853;', '&amp;otimes;':'&#8855;', '&amp;perp;':'&#8869;', '&amp;sdot;':'&#8901;', '&amp;lceil;':'&#8968;', '&amp;rceil;':'&#8969;', '&amp;lfloor;':'&#8970;', '&amp;rfloor;':'&#8971;', '&amp;lang;':'&#9001;', '&amp;rang;':'&#9002;', '&amp;loz;':'&#9674;', '&amp;spades;':'&#9824;', '&amp;clubs;':'&#9827;', '&amp;hearts;':'&#9829;', '&amp;diams;':'&#9830;', '"':'&#34;', '&amp;':'&#38;', '<':'&#60;', '>':'&#62;', '&amp;OElig;':'&#338;', '&amp;oelig;':'&#339;', '&amp;Scaron;':'&#352;', '&amp;scaron;':'&#353;', '&amp;Yuml;':'&#376;', '&amp;circ;':'&#710;', '&amp;tilde;':'&#732;', '&amp;ensp;':'&#8194;', '&amp;emsp;':'&#8195;', '&amp;thinsp;':'&#8201;', '&amp;zwnj;':'&#8204;', '&amp;zwj;':'&#8205;', '&amp;lrm;':'&#8206;', '&amp;rlm;':'&#8207;', '&amp;ndash;':'&#8211;', '&amp;mdash;':'&#8212;', '&amp;lsquo;':'&#8216;', '&amp;rsquo;':'&#8217;', '&amp;sbquo;':'&#8218;', '&amp;ldquo;':'&#8220;', '&amp;rdquo;':'&#8221;', '&amp;bdquo;':'&#8222;', '&amp;dagger;':'&#8224;', '&amp;Dagger;':'&#8225;', '&amp;permil;':'&#8240;', '&amp;lsaquo;':'&#8249;', '&amp;rsaquo;':'&#8250;', '&amp;euro;':'&#8364;' };
		
		

		
		public function Utils()
		{
		}
		
		public static function identicalFiles(sourceFile : File, targetFile : File) : Boolean
		{
			if (sourceFile.isDirectory)
				return false;
			
			var md5StreamForSourceFile : MD5Stream;
			var md5StreamStorageFile : MD5Stream;
			var fileStream : FileStream;
			var byteArray : ByteArray;
			
			var uidForSourceFile : String;
			var uidForStorageFile : String;
			
			if (!sourceFile.exists || !targetFile.exists)
				return true;
			
			md5StreamForSourceFile  = new MD5Stream();
			md5StreamStorageFile = new MD5Stream();
			
			fileStream = new FileStream();
			byteArray = new ByteArray();
			
			fileStream.open(sourceFile, FileMode.READ);
			fileStream.readBytes(byteArray);
			uidForSourceFile = md5StreamForSourceFile.complete(byteArray);
			fileStream.close();
			
			byteArray.clear();
			
			fileStream.open(targetFile, FileMode.READ);
			fileStream.readBytes(byteArray);
			uidForStorageFile = md5StreamForSourceFile.complete(byteArray);
			fileStream.close();
			
			
			if (uidForSourceFile == uidForStorageFile)
				return false;
			
			
			return true;
		}
		
		public static function formatFileSize (size:Number) : String
		{
			var fileSizeStr : String = size.toString();
			
			var gig : Number      = Math.pow(KB, 3);
			var meg : Number      = Math.pow(KB, 2);
			var kil : Number      = KB;
			
			if ( size > gig )
				fileSizeStr = getCorrectSizeValue(size / gig) + " Gb";
			else if ( size > meg )
				fileSizeStr = getCorrectSizeValue(size / meg) + " Mb";
			else if ( size > kil )
				fileSizeStr = getCorrectSizeValue(size / kil) + " Kb";
			else
				fileSizeStr = size.toString() + " bytes";
			
			function getCorrectSizeValue (actualSize : Number) : String
			{
				var floatPart : String = actualSize.toString().split(FLOAT_DELIMETR)[1]; // get part after dot
				
				if (!floatPart || floatPart == "0" || floatPart.length <= 2)
					return actualSize.toString();
				
				
				return int(actualSize).toString() + "." + floatPart.substr(0, 2);
			}
			
			return fileSizeStr;
		}
		
		public static function convertEntities(str:String) : String 
		{
			var re					: RegExp = /&\w*;/g
			var entitiesFound		: Array = str.match(re);
			var entitiesConverted	: Object = {};    
			
			var len:int = entitiesFound.length;
			var oldEntity:String;
			var newEntity:String;
			
			for (var i:int = 0; i < len; i++)
			{
				oldEntity = entitiesFound[i];
				newEntity = entityMap[oldEntity];
				
				if (newEntity && !entitiesConverted[oldEntity])
				{
					str = str.split(oldEntity).join(newEntity);
					entitiesConverted[oldEntity] = true;
				}
			}
			
			return convertEntitiesWithAMP(str);
		}
		
		public static function convertEntitiesWithAMP(str:String) : String 
		{
			var re					: RegExp = /&amp;\w*;/g
			var entitiesFound		: Array = str.match(re);
			var entitiesConverted	: Object = {};    
			
			var len:int = entitiesFound.length;
			var oldEntity:String;
			var newEntity:String;
			
			for (var i:int = 0; i < len; i++)
			{
				oldEntity = entitiesFound[i];
				newEntity = entityMapWithAMP[oldEntity];
				
				if (newEntity && !entitiesConverted[oldEntity])
				{
					str = str.split(oldEntity).join(newEntity);
					entitiesConverted[oldEntity] = true;
				}
			}
			
			return str;
		}
		
		public static function convertSpaces(str : String) : String
		{
			var regExp		: RegExp = />[^<>]*</g;
			var expSpaces	: RegExp = / /g;
			
			var matches : Array = str.match(regExp);
			
			for each (var match:String in matches)
			{
				var newValue : String = match.replace(expSpaces, "&#160;");
				
				str = str.replace(match, newValue);
			}
			
			return str;
		}
		
		public static function configureXMLForDisplaying():void
		{
			XML.prettyPrinting = false;
			XML.ignoreWhitespace = true;
		}
		
		public static function configureXMLForPrinting():void
		{
			XML.prettyPrinting = true;
			XML.ignoreWhitespace = false;
		}
		
	}
}