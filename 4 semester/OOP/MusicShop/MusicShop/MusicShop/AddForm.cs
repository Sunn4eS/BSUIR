using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace MusicShop
{
    
    public partial class AddForm : Form
    {
        public class MusicShopManager
        {
            private readonly List<object> _items = new List<object>();

            public void AddItem(object item)
            {
                _items.Add(item);
            }

            public List<object> GetItems()
            {
                return _items;
            }


            Dictionary<string, string[]> ItemParameters = new Dictionary<string, string[]>
            {
                {
                    "Classical Guitar",
                    new string[] { "Brand", "Model", "CountOfStrings", "Price", "HousingType", "Country", "NeckWidth" }
                },
                {
                    "Acoustic Guitar",
                    new string[] { "GuitarType", "Brand", "Model", "CountOfStrings", "Price", "HousingType", "Country" }
                },
                {
                    "Electric Guitar",
                    new string[]
                    {
                        "GuitarType", "PickUpType", "BridgeType", "Brand", "Model", "CountOfStrings", "Price",
                        "HousingType", "Country"
                    }
                },
                { "Guitar Belt", new string[] { "Brand", "Model", "Material", "Price" } },
                { "Guitar Pick", new string[] { "Brand", "Model", "Price", "Color", "Width" } },
                { "Strings", new string[] { "Model", "Brand", "Price", "MinSize", "MaxSize", "Material" } }
            };

            object CreateItem(string itemType, string brand, string model, int countOfString, int price,
                string housingType, string country, double neckWidth, string guitarType,
                string pickUpType, string bridgeType, string material, string color, int width, int minSize,
                int maxSize)
            {

                var factoryMethods =
                    new Dictionary<string, Func<string, string, int, int, string, string, double, string,
                        string, string, string, string, int, int, int, object>>
                    {
                        {
                            "Classical Guitar",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new ClassicalGuitar(b, m, cS, pr, hS, con, nW)
                        },
                        {
                            "Acoustic Guitar",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new AcousticGuitar(gT, b, m, cS, pr, hS, con)
                        },
                        {
                            "Electric Guitar",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new ElectricGuitar(gT, pUt, bT, b, m, cS, pr, hS, con)
                        },
                        {
                            "Guitar Belt",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new Belt(b, m, mat, pr)
                        },
                        {
                            "Guitar Pick",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new GuitarPick(b, m, pr, col, wD)
                        },
                        {
                            "Strings",
                            (b, m, cS, pr, hS, con, nW, gT, pUt, bT, mat, col, wD, min, max) =>
                                new Strings(m, b, pr, min, max, mat)
                        }
                    };

                if (factoryMethods.TryGetValue(itemType, out var factoryMethod))
                {
                    return factoryMethod(brand, model, countOfString, price, housingType, country, neckWidth,
                        guitarType, pickUpType, bridgeType, material, color, width, minSize, maxSize);
                }

                MessageBox.Show($"Item type '{itemType}' is not supported.");
                return null;
            }

            public void ShowInputForm(string itemType)
            {
                if (ItemParameters.TryGetValue(itemType, out var parameters))
                {
                    using (var inputForm = new AddForm(itemType, parameters))
                    {
                        if (inputForm.ShowDialog() == DialogResult.OK)
                        {
                            var inputValues = inputForm.GetInputValues();
                            
                            var brand = inputValues.TryGetValue("Brand", out var brandValue) ? brandValue : "";
                            var model = inputValues.TryGetValue("Model", out var modelValue) ? modelValue : "";
                            var countOfStrings = inputValues.TryGetValue("CountOfStrings", out var countOfStringsValue)
                                ? int.Parse(countOfStringsValue)
                                : 0;
                            var price = inputValues.TryGetValue("Price", out var priceValue)
                                ? int.Parse(priceValue)
                                : 0;
                            var housingType = inputValues.TryGetValue("HousingType", out var housingTypeValue)
                                ? housingTypeValue
                                : "";
                            var country = inputValues.TryGetValue("Country", out var countryValue) ? countryValue : "";
                            var neckWidth = inputValues.TryGetValue("NeckWidth", out var neckWidthValue)
                                ? double.Parse(neckWidthValue)
                                : 0.0;
                            var guitarType = inputValues.TryGetValue("GuitarType", out var guitarTypeValue)
                                ? guitarTypeValue
                                : "";
                            var pickUpType = inputValues.TryGetValue("PickUpType", out var pickUpTypeValue)
                                ? pickUpTypeValue
                                : "";
                            var bridgeType = inputValues.TryGetValue("BridgeType", out var bridgeTypeValue)
                                ? bridgeTypeValue
                                : "";
                            var material = inputValues.TryGetValue("Material", out var materialValue)
                                ? materialValue
                                : "";
                            var color = inputValues.TryGetValue("Color", out var colorValue) ? colorValue : "";
                            var width = inputValues.TryGetValue("Width", out var widthValue)
                                ? int.Parse(widthValue)
                                : 0;
                            var minSize = inputValues.TryGetValue("MinSize", out var minSizeValue)
                                ? int.Parse(minSizeValue)
                                : 0;
                            var maxSize = inputValues.TryGetValue("MaxSize", out var maxSizeValue)
                                ? int.Parse(maxSizeValue)
                                : 0;

                            var item = CreateItem(
                                itemType,
                                brand,
                                model,
                                countOfStrings,
                                price,
                                housingType,
                                country,
                                neckWidth,
                                guitarType,
                                pickUpType,
                                bridgeType,
                                material,
                                color,
                                width,
                                minSize,
                                maxSize
                            );
                            MessageBox.Show($"Created: {item}");
                            _items.Add(item);

                        }
                    }
                }
                else
                {
                    MessageBox.Show($"Item type '{itemType}' is not supported.");
                }
            }
        }

        private readonly Dictionary<string, TextBox> _inputFields = new Dictionary<string, TextBox>();

            public AddForm(string itemType, string[] parameters)
            {
                InitializeComponent();
                Text = $"Create {itemType}";
                SetupForm(parameters);
            }
        

        private void SetupForm(string[] parameters)
        {
            int y = 20;
            foreach (var param in parameters)
            {
                var label = new Label
                {
                    Text = param + ":",
                    Location = new Point(10, y),
                    AutoSize = true
                };
                Controls.Add(label);

                var textBox = new TextBox
                {
                    Location = new Point(120, y),
                    Width = 150,
                    Tag = param
                };
                Controls.Add(textBox);

                _inputFields[param] = textBox;

                y += 40;
            }

            var buttonCreate = new Button
            {
                Text = "Create",
                Location = new Point(100, y + 20),
                DialogResult = DialogResult.OK,
            };
            buttonCreate.Click += (s, e) => Close();
            Controls.Add(buttonCreate);
            
        }

        public Dictionary<string, string> GetInputValues()
        {
            return _inputFields.ToDictionary(f => f.Key, f => f.Value.Text);
        }
    }
}
