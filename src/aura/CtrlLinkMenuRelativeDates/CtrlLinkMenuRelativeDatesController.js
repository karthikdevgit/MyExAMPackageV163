({
  doInit: function(cmp, event) {
    var attributes = [{
        optionText: 'This Week',
        optionValue: 'THIS_WEEK'
      },
      {
        optionText: 'Last Week',
        optionValue: 'LAST_WEEK'
      },
      {
        optionText: 'This Month',
        optionValue: 'THIS_MONTH'
      },
      {
        optionText: 'Last Month',
        optionValue: 'LAST_MONTH'
      },
      {
        optionText: 'This Year',
        optionValue: 'THIS_YEAR'
      },
      {
        optionText: 'Last Year',
        optionValue: 'LAST_YEAR'
      },
      {
        optionText: 'Last 2 Years',
        optionValue: 'LAST_N_YEARS:2'
      }

    ];

    cmp.set("v.attributes", attributes)

  }
})