require 'rails_helper'

describe 'Books API', type: :request do
  let(:first_author) { FactoryBot.create(:author, first_name: 'George', last_name: 'Orwell', age: 60)}
  let(:second_author) { FactoryBot.create(:author, first_name: 'H.G', last_name: 'Wells', age: 70)}

  describe 'GET /books' do
    before do
      FactoryBot.create(:book, title: '1984', author: first_author)
      FactoryBot.create(:book, title: 'The Time Machine', author: second_author)
    end

    it 'returns all books' do
      get '/api/v1/books'

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(2)
      # for us to be able to make this☝🏼 assertion on the number of books in the
      # response body, we need to actually create book records. rspec does't use
      # our default db, it creates a test db that needs to get seeded each time
      # therefore we install the gem `factory_bot_rails` to allow us to do this
      expect(response_body).to eq(
        [
          {
            'id' => 1,
            'title' => '1984',
            'author_name' => 'George Orwell',
            'author_age' => 60
          },
          {
            'id' => 2,
            'title' => 'The Time Machine',
            'author_name' => 'H.G Wells',
            'author_age' => 70
          }
        ]
      )
    end

    it 'returns a subset of books based on limit' do
      get '/api/v1/books', params: { limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq(
        [
          {
            'id' => 1,
            'title' => '1984',
            'author_name' => 'George Orwell',
            'author_age' => 60
          }
        ]
      )
    end

    it 'returns a subset of books based on limit and offset' do
      get '/api/v1/books', params: { limit: 1, offset: 1 }

      expect(response).to have_http_status(:success)
      expect(response_body.size).to eq(1)
      expect(response_body).to eq(
        [
          {
            'id' => 2,
            'title' => 'The Time Machine',
            'author_name' => 'H.G Wells',
            'author_age' => 70
          }
        ]
      )
    end
  end

  describe 'POST /books' do
    it 'creates a new book' do
      expect {
        post '/api/v1/books', params: { 
          book: {title: 'The Martian'},
          author: {first_name: 'Andy', last_name: 'Weir', age: 50}
        }
      }.to change { Book.count }.from(0).to(1)

      expect(Author.count).to eq(1)
      expect(response).to have_http_status(:created)
      expect(response_body).to eq(
      {
          'id' => 1,
          'title' => 'The Martian',
          'author_name' => 'Andy Weir',
          'author_age' => 50
        }
      )
    end
  end

  describe 'DELETE /books/:id' do
    # we can use let to define variables outside the "it" block
    # this makes our tests cleaner and more readable
    # note: let is lazily loaded i.e. won't run until we call `book.id` in the delete url
    # we add the bang (!) to make sure the factory gets created first when the test runs
    let!(:book) { FactoryBot.create(:book, title: '1984', author: first_author) }

    it 'deletes a book' do
      # book = FactoryBot.create(:book, title: '1984', author: 'George Orwell')

      expect{
        delete "/api/v1/books/#{book.id}"
      }.to change { Book.count }.from(1).to(0)

      expect(response).to have_http_status(:no_content)
    end
  end
end
