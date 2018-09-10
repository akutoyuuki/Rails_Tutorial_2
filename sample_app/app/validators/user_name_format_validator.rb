class UserNameFormatValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
        unless value =~ /\A[\w+\-]+\z/i
            record.errors[attribute] << (options[:message] || "はユーザーidとして利用できません")
        end
    end
end