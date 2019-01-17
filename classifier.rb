require 'pry'
require 'set'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'active_support'
require 'active_support/core_ext'

class Classifier
  def matches?(form)
    false
  end
end

class ASPnet < Classifier
  def matches?(form)
    !form.xpath('//input[@type="hidden"][@name="__VIEWSTATEGENERATOR"]').empty?
  end
end

class Drupal < Classifier
  def matches?(form)
    !form.attr('data-drupal-selector').nil?
  end
end

class SalesForce < Classifier
  def matches?(form)
    return true unless form.xpath('//div[contains(@class, "sf_field")]').empty?
    form.attr('action')&.value&.include?('salesforce.com')
  end
end

class ContactForm7 < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?('wpcf7-form')
  end
end

class ConstantContact < Classifier
  def matches?(form)
    form.attr('class')&.value == "constantcontactwidget_form"
  end
end

class Spry < Classifier
  def matches?(form)
    !form.xpath('//span[@id="sprytextfield1"]').empty?
  end
end

class Instapage < Classifier
  def matches?(form)
    form.attr('data')&.value == 'instapage-form'
  end
end

class GravityForms < Classifier
  def matches?(form)
    !form.xpath('//div[contains(@class, "gform_body")]').empty?
  end
end

class Pardot < Classifier
  def matches?(form)
    !form.xpath('//input[@id="pardot_extra_field"]').empty?
  end
end

class MailChimp < Classifier
  def matches?(form)
    form.attr('action')&.value&.include?('list-manage.com')
  end
end

class TractionDK < Classifier
  def matches?(form)
    form.attr('action')&.value&.include?('tractiondk.com')
  end
end

class FastSecureContactForm < Classifier
  def matches?(form)
    !form.xpath('//input[@name="fscf_submitted"]').empty?
  end
end

class WPForms < Classifier
  def matches?(form)
    !form.xpath('//div[@class="wpforms-field-container"]').empty?
  end
end

class DiViBuilder < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("et_pb_contact_form")
  end
end

class BBForm < Classifier
  def matches?(form)
    !form.xpath('//input[@name="bbForm"]').empty?
  end
end

class Search < Classifier
  def matches?(form)
    return true unless form.xpath('//input[@name="s"]').empty?
    !form.xpath('//input[@name="q"]').empty?
  end
end

class Jetpack < Classifier
  def matches?(form)
    !form.xpath('//input[starts-with(@name, "jetpack_")]').empty?
  end
end

class Unbounce < Classifier
  def matches?(form)
    !form.xpath('//div[contains(@class, "lp-pom-form-field")]').empty?
  end
end

class EForm < Classifier
  def matches?(form)
    form.attr('id')&.value&.include?("ipt_fsqm_form")
  end
end

class Formidable < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("frm-show-form")
  end
end

class PipelineDeals < Classifier
  def matches?(form)
    form.attr('action')&.value&.include?('pipelinedeals.com')
  end
end

class Thigital < Classifier
  def matches?(form)
    form.attr('action')&.value&.include?('thigital.la')
  end
end

class CalderaForms < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("caldera_forms_form")
  end
end

class Elementor < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("elementor-form")
  end
end

class WpDevArt < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("wpdevart-forms")
  end
end

class VisualFormBuilderPro < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("vfbp-form")
  end
end

class FormCraft < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("fc-form")
  end
end

class Drip < Classifier
  def matches?(form)
    !form.attr('data-drip-embedded-form').nil?
  end
end

class PressCore < Classifier
  def matches?(form)
    !form.xpath('//input[contains(@value, "presscore")]').empty?
  end
end

class ChronoForms < Classifier
  def matches?(form)
    !form.xpath('//div[contains(@class, "gcore-form-row")]').empty?
  end
end

class MailChimpForWordpress < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("mc4wp-form")
  end
end

class AWeber < Classifier
  def matches?(form)
    form.attr('class')&.value&.include?("af-form-wrapper")
  end
end

CLASSIFIERS = Classifier.descendants
$print_form = true

def classify(f)
  parsed = Nokogiri::HTML(f)
  form = parsed.xpath('//form')
  found = CLASSIFIERS.find { |klass| klass.new.matches?(form) }
  return found if found
  puts form.to_s if $print_form
  binding.pry
  #option = STDIN.gets.chomp
  #return option unless option.empty?
  return 'unknown'
end

def writeToBucket(bucket, data)
  File.open("results/#{bucket}", 'a') { |f| f.write("#{JSON.generate(data)}\n") }
end

File.foreach(ARGV[0]) do |line|
  data = JSON.parse(line)
  puts data.keys.first
  data.values.each do |f|
    classification = classify(f)
    writeToBucket(classification, { data.keys.first => f })
  end
end
