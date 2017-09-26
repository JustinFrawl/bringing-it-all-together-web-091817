class Dog

 attr_accessor :id, :name, :breed
 def initialize(id: nil, name: name, breed: breed)
   @id = id
   @name = name
   @breed = breed
 end

 def self.create_table
   sql=  <<-SQL
     CREATE TABLE IF NOT EXISTS dogs (
       id INT PRIMARY KEY,
       name TEXT,
       breed TEXT
     )
   SQL
   DB[:conn].execute(sql)
 end

 def self.drop_table
   sql = <<-SQL
     DROP TABLE IF EXISTS dogs
   SQL
   DB[:conn].execute(sql)
 end

 def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
 end

 def save
   sql = <<-SQL
   INSERT INTO dogs (name,breed) VALUES (?,?)
   SQL
   DB[:conn].execute(sql,self.name,self.breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   self
 end

 def self.create(id: nil, name: name, breed: breed)
   new_dog = Dog.new(id: id,name: name,breed: breed)
   new_dog.save
   new_dog
 end

 def self.find_by_id(id)
   sql = "SELECT * FROM dogs WHERE id = ?"
   result = DB[:conn].execute(sql, id)[0]
   Dog.new(id: result[0], name: result[1], breed: result[2])
 end

 def self.find_or_create_by(id: nil, name: name, breed: breed)
   dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
     self.find_by_id(dog[0][0])
   else
     self.create(id: nil, name: name, breed: breed)
   end
 end

 def self.find_by_name(name)
   sql = "SELECT * FROM dogs WHERE name = ?"
   result = DB[:conn].execute(sql, name)[0]
   Dog.new(id: result[0], name: result[1], breed: result[2])
 end

 def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end
end
