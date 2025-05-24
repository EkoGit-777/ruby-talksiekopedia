class RoomsController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    rooms = Room.where(participant_1_id: nil).where(participant_2_id: nil)

    render json: rooms
  end

  def create
    passcode = request.headers["Passcode"]
    user = User.find_by(passcode: passcode)
    code = ''
    participant1 = nil
    participant2 = nil
    loop do
      code = SecureRandom.urlsafe_base64(16)
      break code unless Room.exists?(:name => code)
    end
    roomname = code
    if params.key?(:target)
      participant1 = user.id
      participant2 = params[:target]
    else
      roomname = params[:name]
    end
    newRoom = Room.create(name: roomname, code: code, participant_1_id: participant1, participant_2_id: participant2)
    if(newRoom.errors.full_messages.length > 0)
      render json: newRoom.errors.full_messages
    else
      pusher = Pusher::Client.new(
        app_id: '1997663',
        key: '965e719119116a6d8f01',
        secret: '45c9548b64fa36c02742',
        cluster: 'ap1',
        encrypted: true
      )

      pusher.trigger('talksiekopedia', 'new-room', {})
      render json: newRoom
    end
  end

  def view
    passcode = request.headers["Passcode"]
    user = User.find_by(passcode: passcode)
    room = Room.find_by(code: params[:code]).includes(:room_messages).as_json(include: [:room_messages])
    if room
      if(room.participant_1_id == nil && room.participant_2_id == nil)
        render json: room
      else
        if(room.participant_1_id == user.id || room.participant_2_id == user.id)
          render json: room
        end
        render json: { error: "Room not found" }, status: :not_found
      end
    else
      render json: { error: "Room not found" }, status: :not_found
    end
  end

  def message
    passcode = request.headers["Passcode"]
    user = User.find_by(passcode: passcode)
    message = params[:message]
    newMessage = RoomMessage.create(user_id: user.id, room_id: params[:room_id], message: message)

    pusher = Pusher::Client.new(
      app_id: '1997663',
      key: '965e719119116a6d8f01',
      secret: '45c9548b64fa36c02742',
      cluster: 'ap1',
      encrypted: true
    )

    pusher.trigger('talksiekopedia', 'new-chat', {
      user: user,
      date: newMessage.created_at,
      message: message
    })

    if newMessage
      render json: newMessage
    else
      render json: { error: "There is something wrong. Please reload the page" }, status: :unprocessable_entity
    end
  end
end
