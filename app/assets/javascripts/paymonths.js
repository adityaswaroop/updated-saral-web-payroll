$(document).ready(function() {
    total_row_count = document.getElementById('paymonth_count').value;
    //color_salary_calculated_month(total_row_count)
    color_default_month(total_row_count);
});
function update(input,input_type){
    val = document.getElementById(input.id).checked;
    counter = document.getElementById(input.id).value;
    row_count = document.getElementById('paymonth_count').value;
    if(input_type == 'chk_box')
        input_id = 'paymonth_'+counter+'_Lock_Month';
    else if(input_type == 'rd_btn')
    {
        input_id = 'paymonth_'+counter+'_default_month';
        update_other_default_months(input_id,row_count);
        change_row_color("row_num_"+counter,"red");
    }
    set_value(input_id,val);

}

function set_value(input_id,val){
    document.getElementById(input_id).value = val;
}

function update_other_default_months(except_input_id,count){
    for(i=0;i<count;i++)
    {
        var inputid = 'paymonth_'+i+'_default_month';
        if (except_input_id != inputid)
        {
            set_value(inputid,false);
            change_row_color("row_num_"+i,"black");
        }
    }
}

function change_row_color(rowid,color_name){
    document.getElementById(rowid).style.color = color_name;
    //document.getElementById(rowid).style.backgroundColor = '#57a957';
}

function color_default_month(cnt){
    for(var x=0;x<cnt;x++)
    {
        if(document.getElementById('paymonth_'+x+'_default_month').value == 'true')
        { row_num_id = x;break;   }
    }
   change_row_color("row_num_"+row_num_id,"red")
}

//function color_salary_calculated_month(cnt){
//    for(var x=0;x<cnt;x++)
//    {
//        if(document.getElementById('salary_calculated_'+x).value == 'Yes')
//            change_row_color("row_num_"+x,"#5E46D6")
//    }
//}


