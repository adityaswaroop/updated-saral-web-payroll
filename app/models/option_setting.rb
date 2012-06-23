class OptionSetting < ActiveRecord::Base
  attr_accessible :allow_brnch_admin, :appraisal, :approval_flow, :arrears, :asset_tracker, :attdn_intgration, :audit_trail, :bonus_and_exgratia, :country, :currency, :esi_applicable, :gratuity, :help_desk, :loans_adv, :lv_atdn_mgmt, :multi_branch, :multi_hr, :multi_pt, :multi_state_pt, :pf_applicable, :pt_applicable, :recruitment, :remibursement, :salary_calc, :tds_applicable, :time_zone, :training, :travel_cummute, :country_id , :voluntary_pf, :date_format

  regex_for_date = /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(-|\/|\\)(19|20)\d\d/i

  belongs_to :country


  validates :salary_calc,
            :format     => { :with => regex_for_date },
            :uniqueness => { :case_sensitive => false }

  delegate :name, :to => :country, :prefix => true

  def self.date_format_type date_value,opt_value
     if date_value != "" && opt_value == 1
       date=date_value.strftime(Global.instance.date_format_type)
     end
     if date_value == "" && opt_value == 2
       date=Global.instance.date_format_type
     end
     return date
  end

  def self.date_format_value
    date_format=OptionSetting.first.date_format
    date_format_value = DateFormat.find_by_date_format(date_format).date_format_value
    return date_format_value
  end

  def self.convert_date aray
     value=[]
     date_format=OptionSetting.first.date_format
     if date_format == "m-Y-d"
       aray.each do |dt|
         if dt=="" || dt == nil
           y=""
         else
           x=Date.strptime("{#{dt}}","{%m-%Y-%d}")
           y=x.strftime("%Y-%m-%d")
         end
         value << y
       end
     end
     if date_format == "m/d/Y"
        aray.each do |dt|
          if dt=="" || dt == nil
            y=""
          else
            x=Date.strptime("{#{dt}}","{%m/%d/%Y}")
            y=x.strftime("%Y-%m-%d")
          end
          value << y
        end
     end
     if date_format == "d/m/y"
       aray.each do |dt|
         if dt=="" || dt == nil
           y=""
         else
           x=Date.strptime("{#{dt}}","{%d/%m/%y}")
           y=x.strftime("%Y-%m-%d")
         end
         value << y
       end
     end
     if date_format == "d-m-y"
        aray.each do |dt|
          if dt=="" || dt == nil
            y=""
          else
            x=Date.strptime("{#{dt}}","{%d-%m-%y}")
            y=x.strftime("%Y-%m-%d")
          end
          value << y
        end
      end
    return value
  end
end
