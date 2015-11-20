module ProMotion
  class Form
    attr_reader :form_data

    def initialize(form_data)
      @form_data = form_data
    end

    # Smartly creates a "dumb" FXForms-compatible form object.
    # It contains the values for every field and also has the
    # instructions on how to build the form.
    def build
      props = properties
      form_struct = Struct.new(:fields, *props) do
        props.each do |p|
          alias_method "set#{p.capitalize}:", "#{p}="
        end
      end
      form_struct.new(form_fields, *values)
    end

  private

    def fields
      @fields ||= begin
        header = nil
        form_data.map do |section|
          rows = Array(section[:cells]).map{ |input| input_data(input) }
          rows.first[:header] = section[:title] if section[:title] && rows.length > 0
          rows.last[:footer] = section[:footer] if section[:footer] && rows.length > 0
          rows
        end.flatten
      end
    end

    def properties
      fields.map{ |f| f[:key] }
    end

    def values
      fields.map{ |f| get_value(f) }
    end

    def form_fields
      fields.map{ |f| f.dup.tap{|f2| f2.delete(:value) } }
    end

    def input_data(input)
      data = {}

      # check for ProMotion helpers
      if input[:image]
        input[:properties] ||= {}
        cell_image = input.delete(:image)
        cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)

        input[:properties]['imageView.image'] = cell_image
        input[:properties]['imageView.layer.masksToBounds'] = true
      end

      # process "before" helper keys
      data.update(FormStyle.to_style(input[:properties])) if input[:properties]
      data.update(FormStyle.to_style(input[:style     ])) if input[:style     ]

      # pass non-helper keys to FXForms
      helpers = [ :cell_class, :name, :style, :properties, :label ]
      (input.keys - helpers).each {|key| data[key] = input[key] }

      # process "after" helper keys
      if input[:title].nil? or input[:title].empty? # FXForms crashes on empty strings
        input[:title] = ' '
      end
      data[:key  ] ||= input[:name ] || input[:title].downcase.gsub(/[^0-9a-z]/i, '_').to_sym
      data[:title] ||= input[:label] || input[:name ].to_s
      data[:cell ] ||= input[:cell_class] if input[:cell_class]

      # valid boolean checks
      if input.key?(:value) && input[:type] == :boolean
        input[:value] = input[:value].to_s.downcase
        data[:value] = true.to_s if input[:value] == true.to_s || input[:value] == "1"
        data[:value] = false.to_s if input[:value] == false.to_s || input[:value] != "1"
      end
      data
    end

    def get_value(f)
      f[:value] || begin
        case f[:type]
        when :date then NSDate.date
        when :time then NSDate.date
        when :datetime then NSDate.date
        when :boolean then true.to_s
        else ""
        end
      end
    end
  end
end

# Fields
# ======
# NSString *const FXFormFieldKey              = @"key";
# NSString *const FXFormFieldType             = @"type";
# NSString *const FXFormFieldClass            = @"class";
# NSString *const FXFormFieldCell             = @"cell";
# NSString *const FXFormFieldTitle            = @"title";
# NSString *const FXFormFieldPlaceholder      = @"placeholder";
# NSString *const FXFormFieldDefaultValue     = @"default";
# NSString *const FXFormFieldOptions          = @"options";
# NSString *const FXFormFieldTemplate         = @"template";
# NSString *const FXFormFieldValueTransformer = @"valueTransformer";
# NSString *const FXFormFieldAction           = @"action";
# NSString *const FXFormFieldSegue            = @"segue";
# NSString *const FXFormFieldHeader           = @"header";
# NSString *const FXFormFieldFooter           = @"footer";
# NSString *const FXFormFieldInline           = @"inline";
# NSString *const FXFormFieldSortable         = @"sortable";
# NSString *const FXFormFieldViewController   = @"viewController";

# Types
# =====
# NSString *const FXFormFieldTypeDefault      = @"default";
# NSString *const FXFormFieldTypeLabel        = @"label";
# NSString *const FXFormFieldTypeText         = @"text";
# NSString *const FXFormFieldTypeLongText     = @"longtext";
# NSString *const FXFormFieldTypeURL          = @"url";
# NSString *const FXFormFieldTypeEmail        = @"email";
# NSString *const FXFormFieldTypePhone        = @"phone";
# NSString *const FXFormFieldTypePassword     = @"password";
# NSString *const FXFormFieldTypeNumber       = @"number";
# NSString *const FXFormFieldTypeInteger      = @"integer";
# NSString *const FXFormFieldTypeUnsigned     = @"unsigned";
# NSString *const FXFormFieldTypeFloat        = @"float";
# NSString *const FXFormFieldTypeBitfield     = @"bitfield";
# NSString *const FXFormFieldTypeBoolean      = @"boolean";
# NSString *const FXFormFieldTypeOption       = @"option";
# NSString *const FXFormFieldTypeDate         = @"date";
# NSString *const FXFormFieldTypeTime         = @"time";
# NSString *const FXFormFieldTypeDateTime     = @"datetime";
# NSString *const FXFormFieldTypeImage        = @"image";
