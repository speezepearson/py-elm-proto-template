"""Demo usage: python --open-browser $THIS_FILE
"""
from pathlib import Path
from aiohttp import web

from reverse_pb2 import ReverseRequest, ReverseResponse

routes = web.RouteTableDef()

@routes.get('/')
async def index(request: web.BaseRequest) -> web.StreamResponse:
    return web.FileResponse(Path(__file__).parent / 'index.html')

@routes.post('/api/reverse')
async def reverse(request: web.BaseRequest) -> web.StreamResponse:
    request_pb = ReverseRequest.FromString(await request.content.read())
    response_pb = ReverseResponse(result=''.join(reversed(request_pb.payload)))
    return web.Response(
        content_type='application/octet-stream',
        body=response_pb.SerializeToString(),
    )

app = web.Application()
app.add_routes(routes)
web.run_app(app, host='localhost', port=8000)
