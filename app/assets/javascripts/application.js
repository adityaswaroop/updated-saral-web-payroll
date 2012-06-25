// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){

      $("#search_field").keyup(function() {
      $.get($("#emp_search").attr("action"), $("#emp_search").serialize(), null, "script");
      return false;
      });

      $("#option_setting_country_id").change(function()
      {
      $.get($("#currency_form").attr("action"), $("#option_setting_country_id").serialize(), null, "script");
      return false;
      });

      $("#salary_head_n_grp_ids").change(function()
      {
      $.get($("#group_details").attr("action"), $("#salary_head_n_grp_ids").serialize(), null, "script");
      return false;
      });

      //-# Begin :-
      $("#option_setting_date_format").change(function(){
      var date_format=this.value;
      if(date_format==="Y-m-d")
      {
      $("#date_format_example").html("\"Display as: 2012-01-25\"");
      }
      if(date_format==="d/m/Y")
      {
      $("#date_format_example").html("\"Display as: 25/01/2012\"");
      }
      if(date_format==="d-m-Y")
      {
      $("#date_format_example").html("\"Display as: 25-01-2012\"");
      }
      if(date_format==="M/d/Y")
      {
      $("#date_format_example").html("\"Display as: Jan/25/2012\"");
      }
      if(date_format==="M-d-Y")
      {
      $("#date_format_example").html("\"Display as: Jan-25-2012\"");
      }
      if(date_format==="Y/m/d")
      {
      $("#date_format_example").html("\"Display as: 2012/01/25\"");
      }
      if(date_format==="d/M/Y")
      {
      $("#date_format_example").html("\"Display as: 25/Jan/2012\"");
      }
      if(date_format==="d-M-Y")
      {
      $("#date_format_example").html("\"Display as: 25-Jan-2012\"");
      }
      if(date_format==="Y/M/d")
      {
      $("#date_format_example").html("\"Display as: 2012/Jan/25\"");
      }
      if(date_format==="Y-M-d")
      {
      $("#date_format_example").html("\"Display as: 2012-Jan-25\"");
      }
      if(date_format==="MM d Y")
      {
      $("#date_format_example").html("\"Display as: January 25, 2012\"");
      }
      if(date_format==="d MM Y")
      {
      $("#date_format_example").html("\"Display as: 25 January 2012\"");
      }
      if(date_format==="m/d/Y")
      {
      $("#date_format_example").html("\"Display as: 01/25/2012\"");
      }
      if(date_format==="m-Y-d")
      {
      $("#date_format_example").html("\"Display as: 01-2012-25\"");
      }
      if(date_format==="d/m/y")
      {
      $("#date_format_example").html("\"Display as: 25/01/12\"");
      }
      if(date_format==="d-m-y")
      {
      $("#date_format_example").html("\"Display as: 25-01-12\"");
      }
      });
      //-# End

      if($("#option_setting_pf_applicable").attr('checked')) {
      $("#option_setting_voluntary_pf").attr("disabled", false);
      }


    $("#option_setting_pf_applicable").click(function() {

      if($("#option_setting_pf_applicable").attr('checked')) {
      $("#option_setting_voluntary_pf").attr("disabled", false);
      }
      else
      {
      $("#option_setting_voluntary_pf").attr("disabled", true);
      $("#option_setting_voluntary_pf").attr("checked", false);
      }
      });

      $("#option_setting_pt_applicable").click(function() {

      if($("#option_setting_pt_applicable").attr('checked')) {
      $("#option_setting_multi_state_pt").attr("disabled", false);
      $("#option_setting_multi_pt").attr("disabled", false);
      }
      else
      {
      $("#option_setting_multi_state_pt").attr("disabled", true);
      $("#option_setting_multi_pt").attr("disabled", true);
      }
      });


      });
