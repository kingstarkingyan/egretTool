package nodep.util
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * 文件工具类
	 * @author nodep
	 */	
	public class FileUtil
	{	
		private static var _callBack:Function;
		private static var _arg:String;
		/**
		 * 选择一个文件目录
		 * @param callBack 回执函数,参数一个或2个,第一个为File,第二个为你传递进来的字符串
		 * @param arg
		 */		
		public static function choosePath(callBack:Function,title:String,arg:String = null):void{
			_callBack = callBack;
			_arg = arg;
			var file:File = new File();
			file.browseForDirectory(title);
			file.addEventListener(Event.SELECT,pathSelectHandler);
		}
		
		/**
		 * 路径选择完成
		 * @param evt
		 */		
		private static function pathSelectHandler(evt:Event):void{
			var file:File = evt.target as File;
			if(_callBack!=null){
				if(_arg!=null)
					_callBack(file,_arg);
				else
					_callBack(file);
			}
		}
		
		private static const IMG:Array = ["png","jpg"];
		
		/**
		 * 是否是图片资源的名称
		 * @param name
		 * @return 
		 */		
		public static function isImageForMac(name:String):Boolean{
			var args:Array = name.split(".");
			if(args.length<=1)
				return false;
			return IMG.indexOf((args[args.length-1] as String).toLowerCase())>=0;
		}
		
		/**
		 * 是某个类型的文件 
		 * @param name
		 * @param type
		 * @return 
		 */		
		public static function isTypeFileForMac(name:String,type:String):Boolean{
			var args:Array = name.split(".");
			return (args[args.length-1] as String).toLowerCase() == type.toLocaleLowerCase();
		}
		
		/**
		 * 获取文件名排除扩展名
		 * @param str 文件名全称
		 * @return
		 */		
		public static function getFileName(str:String):String{
			var args:Array = str.split(".");
			args.pop();
			var n:String = "";
			while(args.length>0){
				n = n+args.shift();
			}
			return n;
		}
		
		/**
		 * 获取文件扩展名
		 * @param str 文件名全称
		 * @return
		 */		
		public static function getFileType(str:String):String{
			var args:Array = str.split(".");
			return args[args.length-1];
		}
		
		/**
		 * 拷贝文件到制定目录
		 * @param file
		 * @param url
		 */		
		public static function copyFileTo(file:File,url:String):void{
			var saveBytes:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ);
			fileStream.readBytes(saveBytes);
			fileStream.close();
			fileStream = new FileStream();
			fileStream.open(new File(url),FileMode.WRITE);
			fileStream.writeBytes(saveBytes);
			fileStream.close();
		}
		
		/**
		 * 获取文件的二进制内容
		 * @param url 地址或文件对象
		 * @return
		 */		
		public static function getBytes(url:*):ByteArray{
			var saveBytes:ByteArray = new ByteArray();
			var file:File;
			if(url is File)
				file = url;
			else
				file = new File(url);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ);
			fileStream.readBytes(saveBytes);
			fileStream.close();
			return saveBytes;
		}
		
		/**
		 * 获取文件的字符串
		 * @param url
		 * @return 
		 */		
		public static function getStr(url:*):String{
			var file:File;
			if(url is File)
				file = url;
			else
				file = new File(url);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ);
			return fileStream.readUTFBytes(fileStream.bytesAvailable);
		}
		
		/**
		 * 保存字符串到对应的文件
		 * @param url
		 * @param str
		 */		
		public static function saveStr(url:*,str:String):void{
			var file:File;
			if(url is File)
				file = url;
			else
				file = new File(url);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.WRITE);
			fileStream.writeUTFBytes(str);
		}
		
		/**
		 * 存档
		 * @param bts
		 * @param url
		 */		
		public static function saveFile(bts:ByteArray,url:String):void{
			var fileStream:FileStream = new FileStream();
			fileStream.open(new File(url),FileMode.WRITE);
			fileStream.writeBytes(bts);
			fileStream.close();
		}
		
		/**
		 * 两个文件是否不一样
		 * @param url1
		 * @param url2
		 * @return
		 */		
		public static function isDifferent(url1:String,url2:String):Boolean{
			var file1:File = new File(url1);
			var file2:File = new File(url2);
			if(!file1.exists||!file2.exists)//如果是一个新的文件
				return true;
			var b1:ByteArray = new ByteArray();
			var b2:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(file1,FileMode.READ);
			fileStream.readBytes(b1);
			fileStream.close();
			fileStream.open(file2,FileMode.READ);
			fileStream.readBytes(b2);
			fileStream.close();
			if(b1.length!=b2.length)
				return true;
			for(var i:int=0;i<b1.length;i++){
				if(b1[i]!=b2[i])
					return true;
			}
			return false;
		}
	}
}