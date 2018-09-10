class EmailFormatValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
        unless value =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
            record.errors[attribute] << (options[:message] || "はメールアドレスではありません")
        end
    end
end