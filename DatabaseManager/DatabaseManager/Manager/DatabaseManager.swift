//
//  DatabaseManager.swift
//  DatabaseManager
//
//  Created by yu qin on 2019/8/5.
//  Copyright © 2019 yu qin. All rights reserved.
//

import UIKit

// 库名
let db_file_name = "jk.sqlite"

// 表名
let table_message = "message"

// 建表语句
let sql_create_message = "CREATE TABLE IF NOT EXISTS \(table_message) ( \n" +
    "id INTEGER PRIMARY KEY AUTOINCREMENT, \n" +
    "name TEXT, \n" +
    "age INTEGER \n" +
"); \n"


class DatabaseManager: NSObject {
    
    static let shared = DatabaseManager()
    
    lazy private var dataBaseQueue: FMDatabaseQueue = {
        let dataBaseQueue = FMDatabaseQueue(path: dbFilePath())
        return dataBaseQueue!
    }()

    
    /**
     * 表配置
     */
    func openDB() {
        createTable(sql_create_message)
    }

    /**
     * 数据库文件路径
     */
    fileprivate func dbFilePath() -> String {
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let dbFilePath = documentsDirectory! + "/" + db_file_name
        print(dbFilePath)
        return dbFilePath
    }
    
    /**
     * 建表
     */
    fileprivate func createTable(_ sql: String) {
        // 2.执行SQL语句
        // 在FMDB中除了查询外, 都称之为更新
        dataBaseQueue.inDatabase { (db) in
            db.executeUpdate(sql, withArgumentsIn: [])
        }
    }
    
    
    
    
    /**********************以下是模型存储*********************/
    
    
    
    /**
     * 根据类建表
     */
    func createTable(_ cls: AnyClass) {
        
        let className = getClassName(cls: cls)
        var sql = "CREATE TABLE IF NOT EXISTS \(className) ( id integer primary key autoincrement"
        var count: UInt32 = 0
        
        // 获取属性列表
        let ivars = class_copyIvarList(cls, &count)
        
        // 拼接sql
        for i in 0 ..< count {
            let ivar = ivars![Int(i)]
            let name = ivar_getName(ivar)
            let key = String.init(utf8String: name!)!
            sql.append(",\(key) text not null")
        }
        sql.append(")")
        
        dataBaseQueue.inDatabase { (db) in
            let result = db.executeStatements(sql)
            if (result) {
                print("表: 创建成功")
            } else {
                print("表: 创建失败")
            }

        }
    }
    
    
    /**
     * 添加
     */
    
    func insert(_ model: AnyObject) {
        
        let cls: AnyClass! = object_getClass(model)
        let clsName = getClassName(cls: cls)
        
        dataBaseQueue.inDatabase { (db) in
            if db.tableExists(clsName) {
                // 设置缓存,提高效率
                db.shouldCacheStatements = true
                var count: UInt32 = 0
                var keys = "("
                var values = "("
                var mArr: [Any] = []
                
                // 获取属性列表
                let ivars = class_copyIvarList(cls, &count)
                
                // 拼接sql
                for i in 0 ..< count {
                    let ivar = ivars![Int(i)]
                    let name = ivar_getName(ivar)
                    let key = String.init(utf8String: name!)!
                    
                    // 有值才存储
                    if let value = model.value(forKey: key) {
                        keys.append("\(key), ")
                        values.append("?, ")
                        mArr.append(value)
                    }
                }
                keys = keys.substring(to: keys.count - 3)
                keys.append(")")
                values = values.substring(to: values.count - 3)
                values.append(")")
                
                free(ivars)
                
                let sql = "insert into \(clsName) \(keys) values \(values)"
                db.executeUpdate(sql, withArgumentsIn: mArr)
                print(sql)
            }
        }
        
    }
    
    /**
     * 查
     */
    func getAll(cls: AnyClass) {
    
        let className = getClassName(cls: cls)
        
        let classType: BaseModel.Type = cls as! BaseModel.Type
        dataBaseQueue.inDatabase { (db) in
            
            if db.tableExists(className) {
                let sql = "select * from " + className
                let resultSet = db.executeQuery(sql, withParameterDictionary: nil)
                var mArr: [BaseModel] = []
                while (resultSet?.next())! {
                    let model = classType.init()
                    var count: UInt32 = 0
                    let ivars = class_copyIvarList(cls, &count)
                    for i in 0 ..< count {
                        let ivar = ivars![Int(i)]
                        let name = ivar_getName(ivar)
                        let key = String.init(utf8String: name!)!
                        
                        let value = resultSet?.string(forColumn: key)
                        model.setValue(value, forKey: key)
                    }
                    mArr.append(model)
                }
                print(mArr)
            }
        }
    }
    
    
    /**
     * 类名
     */
    fileprivate func getClassName(cls: AnyClass) -> String {
        let clsName = NSStringFromClass(cls).components(separatedBy: ".").last!
        return clsName
    }
    

}
