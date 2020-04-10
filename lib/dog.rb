class Dog
    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id, @name, @breed = id, name, breed;
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE 
            IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id_num)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        new_dog = DB[:conn].execute(sql, id_num).flatten
        Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ? AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs(name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self # refers to the object intance!
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ? 
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end