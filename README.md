# API demo
> An example of how easily you can introduce FirstDerm's API in your product.

![](https://www.firstderm.com/wp-content/uploads/2017/01/firstderm_tm.png)

## Installation

Clone the repository:

```sh
git clone https://github.com/polyrand/firstderm_demo.git
```

Install the requirements in your virtual environment:

```bash
pip install fastapi
pip install python-multipart
pip install uvicorn
pip install Jinja2
```

## Usage example

You can run the app using [uvicorn](https://github.com/encode/uvicorn):

```python
uvicorn main:app --host 0.0.0.0 --port 8000
# or...
python3 main.py
```

## Release History

* 2.0
    * Update to the new API
* 1.0
    * Initial post


## Meta

Ricardo Ander-Egg Aguilar – [@ricardoanderegg](https://twitter.com/ricardoanderegg) –

[https://github.com/polyrand/](https://github.com/polyrand/)

## Contributing

1. Fork it (<https://github.com/polyrand/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

