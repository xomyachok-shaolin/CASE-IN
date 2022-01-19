using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CASE_IN {
    public partial class Form1 : Form {
        public Form1() {
            InitializeComponent();
        }

        private void btnExecuteScript_Click(object sender, EventArgs e) {

        }

        private void Form1_Load(object sender, EventArgs e) {
            // Set the MinDate and MaxDate.
            dateTimePicker.MinDate = new DateTime(2015,01,01, 06, 00, 00);
            dateTimePicker.MaxDate = new DateTime(2016, 01, 01, 06, 00, 00);
        }
    }
}
