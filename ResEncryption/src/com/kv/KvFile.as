package com.kv
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * Kv文件
	 * @author 62344
	 */	
	public class KvFile extends File
	{
		private var _url:String;
		private var _data:Object = new Object();
		/**
		 * 创建一个文件
		 * @param url 
		 */		
		public function KvFile(url:String)
		{
			super(url);
			_url = url;
		}
		
		/**
		 * 通过文本进行初始化
		 */		
		public function loadValues():void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(this,FileMode.READ);
			var str:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			_data = JSON.parse(str);
			fileStream.close();
		}
		
		/**
		 * 更新一个数值
		 * @param key
		 * @param value 
		 */		
		public function setValue(key:String,value:String):void
		{
			_data[key] = value;
			var fileStream:FileStream = new FileStream();
			fileStream.open(this,FileMode.WRITE);
			fileStream.writeUTFBytes(JSON.stringify(_data));
			fileStream.close();
		}
		
		/**
		 * 获取某个字段
		 * @return
		 */		
		public function getValue(key:String):*
		{
			if(_data.hasOwnProperty(key))
				return _data[key];
			return null;
		}
	}
}