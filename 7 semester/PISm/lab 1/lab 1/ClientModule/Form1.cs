using Npgsql;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text.Unicode;
using System.Windows.Forms;

namespace BankClientsApp
{
    public partial class MainForm : Form
    {
        
        private readonly DatabaseService _dbService;

        private TextBox txtLastName;
        private TextBox txtFirstName;
        private TextBox txtPatronymic;
        private DateTimePicker dtpBirthDate;
        private TextBox txtPassportSeries;
        private TextBox txtPassportNumber;
        private TextBox txtIssuedBy;
        private DateTimePicker dtpIssueDate;
        private MaskedTextBox txtIdNumber;
        private TextBox txtBirthPlace;
        private ComboBox cmbActualCity;
        private TextBox txtActualAddress;
        private MaskedTextBox txtHomePhone;
        private MaskedTextBox txtMobilePhone;
        private TextBox txtEmail;
        private TextBox txtWorkplace;
        private TextBox txtPosition;
        private ComboBox cmbMaritalStatus;
        private ComboBox cmbCitizenship;
        private ComboBox cmbDisability;
        private CheckBox chkPensioner;
        private TextBox txtMonthlyIncome;
        private CheckBox chkMilitary;

        private DataGridView dgvClients;
        private Button btnSave;
        private Button btnDelete;
        private Button btnClear;

        private int _selectedClientId = 0;

        public MainForm()
        {
            string connectionString = "Host=localhost;Port=5432;Database=BankSystem;Username=postgres;Password=08062023;Client Encoding = UTF8;";
            _dbService = new DatabaseService(connectionString);

            InitializeComponentProgrammatically();
            LoadLookupData();
            LoadClientsList();
        }

        #region Инициализация интерфейса (Windows Forms)
        private void InitializeComponentProgrammatically()
        {
            this.Text = "Учет клиентов банка — Вариант 3";
            this.Size = new Size(1280, 750);
            this.StartPosition = FormStartPosition.CenterScreen;

            SplitContainer mainContainer = new SplitContainer
            {
                Dock = DockStyle.Fill,
                SplitterDistance = 450,
                IsSplitterFixed = false
            };
            this.Controls.Add(mainContainer);

            Panel leftPanel = new Panel { Dock = DockStyle.Fill, AutoScroll = true, Padding = new Padding(10) };
            mainContainer.Panel1.Controls.Add(leftPanel);

            GroupBox gbClientInfo = new GroupBox
            {
                Text = "Данные клиента (Вариант 3)",
                Dock = DockStyle.Top,
                AutoSize = true,
                Padding = new Padding(10)
            };
            leftPanel.Controls.Add(gbClientInfo);

            TableLayoutPanel layout = new TableLayoutPanel
            {
                ColumnCount = 2,
                AutoSize = true,
                Dock = DockStyle.Top
            };
            layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 180F));
            layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            gbClientInfo.Controls.Add(layout);

            int row = 0;
            void AddRow(string labelText, Control control)
            {
                Label lbl = new Label { Text = labelText, AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(3, 6, 3, 6) };
                control.Width = 220;
                layout.Controls.Add(lbl, 0, row);
                layout.Controls.Add(control, 1, row);
                row++;
            }

            txtLastName = new TextBox();
            txtFirstName = new TextBox();
            txtPatronymic = new TextBox();
            dtpBirthDate = new DateTimePicker { Format = DateTimePickerFormat.Short };
            txtPassportSeries = new TextBox { MaxLength = 10 };
            txtPassportNumber = new TextBox { MaxLength = 20 };
            txtIssuedBy = new TextBox();
            dtpIssueDate = new DateTimePicker { Format = DateTimePickerFormat.Short };

            txtIdNumber = new MaskedTextBox("0000000L000LL0");
            txtBirthPlace = new TextBox();
            cmbActualCity = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            txtActualAddress = new TextBox();

            txtHomePhone = new MaskedTextBox("+375 (00) 000-00-00");
            txtMobilePhone = new MaskedTextBox("+375 (00) 000-00-00");
            txtEmail = new TextBox();
            txtWorkplace = new TextBox();
            txtPosition = new TextBox();

            cmbMaritalStatus = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbCitizenship = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbDisability = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };

            chkPensioner = new CheckBox { Text = "Да" };
            txtMonthlyIncome = new TextBox();
            chkMilitary = new CheckBox { Text = "Да" };

            AddRow("Фамилия *:", txtLastName);
            AddRow("Имя *:", txtFirstName);
            AddRow("Отчество *:", txtPatronymic);
            AddRow("Дата рождения *:", dtpBirthDate);
            AddRow("Серия паспорта *:", txtPassportSeries);
            AddRow("№ паспорта *:", txtPassportNumber);
            AddRow("Кем выдан *:", txtIssuedBy);
            AddRow("Дата выдачи *:", dtpIssueDate);
            AddRow("Идент. номер *:", txtIdNumber);
            AddRow("Место рождения *:", txtBirthPlace);
            AddRow("Город прож. *:", cmbActualCity);
            AddRow("Адрес прож. *:", txtActualAddress);
            AddRow("Телефон дом:", txtHomePhone);
            AddRow("Телефон моб:", txtMobilePhone);
            AddRow("E-mail:", txtEmail);
            AddRow("Место работы:", txtWorkplace);
            AddRow("Должность:", txtPosition);
            AddRow("Сем. положение *:", cmbMaritalStatus);
            AddRow("Гражданство *:", cmbCitizenship);
            AddRow("Инвалидность *:", cmbDisability);
            AddRow("Пенсионер *:", chkPensioner);
            AddRow("Доход (руб.):", txtMonthlyIncome);
            AddRow("Военнообязанный *:", chkMilitary);

            FlowLayoutPanel pnlButtons = new FlowLayoutPanel { Dock = DockStyle.Top, Height = 45, Padding = new Padding(5) };
            btnSave = new Button { Text = "Сохранить", Width = 100, Height = 32, BackColor = Color.LightGreen };
            btnClear = new Button { Text = "Очистить", Width = 100, Height = 32 };
            btnDelete = new Button { Text = "Удалить", Width = 100, Height = 32, BackColor = Color.LightCoral, Enabled = false };

            btnSave.Click += BtnSave_Click;
            btnClear.Click += (s, e) => ClearForm();
            btnDelete.Click += BtnDelete_Click;

            pnlButtons.Controls.AddRange(new Control[] { btnSave, btnClear, btnDelete });
            leftPanel.Controls.Add(pnlButtons);
            pnlButtons.BringToFront();

            Panel rightPanel = new Panel { Dock = DockStyle.Fill, Padding = new Padding(10) };
            mainContainer.Panel2.Controls.Add(rightPanel);

            Label lblTitle = new Label { Text = "Список клиентов (сортировка по Фамилии)", Dock = DockStyle.Top, Font = new Font(FontFamily.GenericSansSerif, 10, FontStyle.Bold), Height = 25 };
            dgvClients = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                AllowUserToAddRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells
            };
            dgvClients.SelectionChanged += DgvClients_SelectionChanged;

            rightPanel.Controls.Add(dgvClients);
            rightPanel.Controls.Add(lblTitle);
        }
        #endregion

        #region Загрузка данных через DatabaseService
        private void LoadLookupData()
        {
            try
            {
                cmbActualCity.DataSource = _dbService.GetLookupData("cities", "name");
                cmbMaritalStatus.DataSource = _dbService.GetLookupData("marital_statuses", "status_name");
                cmbCitizenship.DataSource = _dbService.GetLookupData("citizenships", "country_name");
                cmbDisability.DataSource = _dbService.GetLookupData("disability_statuses", "group_name");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка загрузки справочников из БД: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void LoadClientsList()
        {
            try
            {
                dgvClients.DataSource = null;
                dgvClients.DataSource = _dbService.GetClientsSortedByLastName();

                if (dgvClients.Columns["Id"] != null) dgvClients.Columns["Id"].Visible = false;
                if (dgvClients.Columns["LastName"] != null) dgvClients.Columns["LastName"].HeaderText = "Фамилия";
                if (dgvClients.Columns["FirstName"] != null) dgvClients.Columns["FirstName"].HeaderText = "Имя";
                if (dgvClients.Columns["Patronymic"] != null) dgvClients.Columns["Patronymic"].HeaderText = "Отчество";
                if (dgvClients.Columns["BirthDate"] != null) dgvClients.Columns["BirthDate"].HeaderText = "Дата рожд.";
                if (dgvClients.Columns["PassportSeries"] != null) dgvClients.Columns["PassportSeries"].HeaderText = "Серия";
                if (dgvClients.Columns["PassportNumber"] != null) dgvClients.Columns["PassportNumber"].HeaderText = "Номер";
                if (dgvClients.Columns["IdNumber"] != null) dgvClients.Columns["IdNumber"].HeaderText = "Идент. номер";
                if (dgvClients.Columns["ActualCityName"] != null) dgvClients.Columns["ActualCityName"].HeaderText = "Город";
                if (dgvClients.Columns["MobilePhone"] != null) dgvClients.Columns["MobilePhone"].HeaderText = "Моб. тел";
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка загрузки списка клиентов: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        #endregion

        #region Обработка событий кнопок и формы
        private void BtnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Client client = new Client
                {
                    Id = _selectedClientId,
                    LastName = txtLastName.Text,
                    FirstName = txtFirstName.Text,
                    Patronymic = txtPatronymic.Text,
                    BirthDate = dtpBirthDate.Value,
                    PassportSeries = txtPassportSeries.Text,
                    PassportNumber = txtPassportNumber.Text,
                    IssuedBy = txtIssuedBy.Text,
                    IssueDate = dtpIssueDate.Value,
                    IdNumber = txtIdNumber.Text.Replace(" ", "").ToUpper(),
                    BirthPlace = txtBirthPlace.Text,
                    ActualCityId = ((LookupItem)cmbActualCity.SelectedItem)?.Id ?? 0,
                    ActualAddress = txtActualAddress.Text,

                    HomePhone = txtHomePhone.MaskCompleted ? txtHomePhone.Text : null,
                    MobilePhone = txtMobilePhone.MaskCompleted ? txtMobilePhone.Text : null,
                    Email = string.IsNullOrWhiteSpace(txtEmail.Text) ? null : txtEmail.Text,
                    Workplace = string.IsNullOrWhiteSpace(txtWorkplace.Text) ? null : txtWorkplace.Text,
                    Position = string.IsNullOrWhiteSpace(txtPosition.Text) ? null : txtPosition.Text,

                    MaritalStatusId = ((LookupItem)cmbMaritalStatus.SelectedItem)?.Id ?? 0,
                    CitizenshipId = ((LookupItem)cmbCitizenship.SelectedItem)?.Id ?? 0,
                    DisabilityId = ((LookupItem)cmbDisability.SelectedItem)?.Id ?? 0,

                    IsPensioner = chkPensioner.Checked,
                    IsLiableForMilitaryService = chkMilitary.Checked,
                    MonthlyIncome = decimal.TryParse(txtMonthlyIncome.Text, out decimal income) ? income : (decimal?)null
                };

                ClientValidator.Validate(client);

                if (_selectedClientId == 0)
                {
                    _dbService.AddClient(client);
                }
                else
                {
                    _dbService.UpdateClient(client);
                }

                MessageBox.Show("Данные клиента успешно сохранены!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                ClearForm();
                LoadClientsList();
            }
            catch (ArgumentException ex)
            {
                MessageBox.Show(ex.Message, "Предупреждение валидации", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (PostgresException ex)
            {
                // Перехват уникальных ограничений БД PostgreSQL (Пункты 1, 2, 3 задания)
                if (ex.SqlState == "23505")
                {
                    if (ex.ConstraintName == "uk_full_name_dob")
                        MessageBox.Show("Ошибка: Клиент с такими ФИО и датой рождения уже существует!", "Ошибка дублирования", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    else if (ex.ConstraintName == "uk_passport")
                        MessageBox.Show("Ошибка: Клиент с такими серией и номером паспорта уже существует!", "Ошибка дублирования", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    else if (ex.ConstraintName == "clients_id_number_key")
                        MessageBox.Show("Ошибка: Клиент с таким идентификационным номером уже существует!", "Ошибка дублирования", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    else
                        MessageBox.Show($"Запись уже существует в базе данных: {ex.MessageText}", "Ошибка СУБД", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                else
                {
                    MessageBox.Show($"Ошибка базы данных: {ex.MessageText}", "Ошибка СУБД", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Непредвиденная ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void BtnDelete_Click(object sender, EventArgs e)
        {
            if (_selectedClientId == 0) return;

            var result = MessageBox.Show("Вы действительно хотите удалить выбранного клиента?", "Подтверждение", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (result == DialogResult.Yes)
            {
                try
                {
                    _dbService.DeleteClient(_selectedClientId);
                    MessageBox.Show("Клиент успешно удален!", "Информация", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    ClearForm();
                    LoadClientsList();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка при удалении: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void DgvClients_SelectionChanged(object sender, EventArgs e)
        {
            if (dgvClients.SelectedRows.Count > 0)
            {
                var selectedClient = (Client)dgvClients.SelectedRows[0].DataBoundItem;
                PopulateForm(selectedClient);
            }
        }

        private void PopulateForm(Client c)
        {
            _selectedClientId = c.Id;
            txtLastName.Text = c.LastName;
            txtFirstName.Text = c.FirstName;
            txtPatronymic.Text = c.Patronymic;
            dtpBirthDate.Value = c.BirthDate;
            txtPassportSeries.Text = c.PassportSeries;
            txtPassportNumber.Text = c.PassportNumber;
            txtIssuedBy.Text = c.IssuedBy;
            dtpIssueDate.Value = c.IssueDate;
            txtIdNumber.Text = c.IdNumber;
            txtBirthPlace.Text = c.BirthPlace;

            SetComboValue(cmbActualCity, c.ActualCityId);
            txtActualAddress.Text = c.ActualAddress;

            txtHomePhone.Text = c.HomePhone;
            txtMobilePhone.Text = c.MobilePhone;
            txtEmail.Text = c.Email;
            txtWorkplace.Text = c.Workplace;
            txtPosition.Text = c.Position;

            SetComboValue(cmbMaritalStatus, c.MaritalStatusId);
            SetComboValue(cmbCitizenship, c.CitizenshipId);
            SetComboValue(cmbDisability, c.DisabilityId);

            chkPensioner.Checked = c.IsPensioner;
            txtMonthlyIncome.Text = c.MonthlyIncome?.ToString();
            chkMilitary.Checked = c.IsLiableForMilitaryService;

            btnSave.Text = "Обновить";
            btnDelete.Enabled = true;
        }

        private void ClearForm()
        {
            _selectedClientId = 0;
            txtLastName.Clear();
            txtFirstName.Clear();
            txtPatronymic.Clear();
            dtpBirthDate.Value = DateTime.Now;
            txtPassportSeries.Clear();
            txtPassportNumber.Clear();
            txtIssuedBy.Clear();
            dtpIssueDate.Value = DateTime.Now;
            txtIdNumber.Clear();
            txtBirthPlace.Clear();
            txtActualAddress.Clear();
            txtHomePhone.Clear();
            txtMobilePhone.Clear();
            txtEmail.Clear();
            txtWorkplace.Clear();
            txtPosition.Clear();
            txtMonthlyIncome.Clear();
            chkPensioner.Checked = false;
            chkMilitary.Checked = false;

            if (cmbActualCity.Items.Count > 0) cmbActualCity.SelectedIndex = 0;
            if (cmbMaritalStatus.Items.Count > 0) cmbMaritalStatus.SelectedIndex = 0;
            if (cmbCitizenship.Items.Count > 0) cmbCitizenship.SelectedIndex = 0;
            if (cmbDisability.Items.Count > 0) cmbDisability.SelectedIndex = 0;

            btnSave.Text = "Сохранить";
            btnDelete.Enabled = false;
            dgvClients.ClearSelection();
        }

        private void SetComboValue(ComboBox cmb, int id)
        {
            foreach (LookupItem item in cmb.Items)
            {
                if (item.Id == id)
                {
                    cmb.SelectedItem = item;
                    break;
                }
            }
        }
        #endregion
    }
}