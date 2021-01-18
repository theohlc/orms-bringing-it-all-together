class Dog
    attr_accessor :breed, :name, :id

    def initialize(data)
        @name = data[:name]
        @breed = data[:breed]
        @id = data[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name,
                breed
            )
            SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if @id
            update
        else
            sql = <<-SQL
                INSERT INTO dogs(name, breed)
                VALUES(?, ?)
                SQL
            DB[:conn].execute(sql, name, breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, name, breed, id)
    end

    def self.create(data)
        new(data).save       
    end
    
    def self.new_from_db(row)
        data = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        
        new(data)
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
        new_from_db(row)
    end

    def self.find_or_create_by(data)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
            
            SQL
        
        row = DB[:conn].execute(sql, data[:name], data[:breed])
        
        if !row.empty?
            dog = new_from_db(row[0])
        else
            create(data)
        end
        
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            SQL

        row = DB[:conn].execute(sql, name)[0]
        new_from_db(row)
    end
            


end